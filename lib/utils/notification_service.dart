import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/activity.dart';
import '../services/recurrence_engine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Nombre de jours de la fenêtre glissante pour la planification d'alarmes futures
  static const int slidingWindowDays = 30;

  /// Initialisation du plugin de notifications locales et du fuseau horaire réel
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialisation de la base de données des fuseaux horaires
    tz.initializeTimeZones();

    // 2. Détection dynamique du fuseau horaire local de l'appareil
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('Fuseau horaire configuré dynamiquement : $currentTimeZone');
    } catch (e) {
      debugPrint('Erreur lors de la détection du fuseau horaire ($e), repli Europe/Paris ou UTC');
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Paris'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    // 3. Paramètres d'initialisation pour Android et iOS
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification cliquée avec payload: ${response.payload}');
      },
    );

    // 4. Création du canal de notification haute priorité sur Android
    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        const channel = AndroidNotificationChannel(
          'activities_reminder_channel_v2',
          'Rappels d\'activités & Alarmes exactes',
          description:
              'Notifications et alarmes exactes déclenchées à la minute près avant vos activités',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
        await androidImpl.createNotificationChannel(channel);
      }
    }

    _isInitialized = true;
  }

  /// Demande des permissions de base (POST_NOTIFICATIONS pour Android 13+)
  Future<bool> requestPermissions() async {
    bool granted = true;

    // Permission Android 13+
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final androidGranted =
          await androidImpl.requestNotificationsPermission() ?? false;
      granted = granted && androidGranted;
    }

    // Permission iOS
    final iosImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final iosGranted = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      granted = granted && iosGranted;
    }

    return granted;
  }

  /// Vérifie si la permission d'alarme exacte est accordée (Android 12+ / API 31+)
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return await androidImpl.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  /// Demande à l'utilisateur d'activer les alarmes exactes dans les réglages système
  Future<void> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return;
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestExactAlarmsPermission();
    }
  }

  /// Vérifie si l'optimisation de batterie est ignorée pour l'application
  Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  /// Demande l'exemption d'optimisation de batterie
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  /// Génère un identifiant entier 32-bit unique pour une occurrence d'activité
  int _getOccurrenceNotificationId(String activityId, DateTime date) {
    final key = '$activityId-${date.year}-${date.month}-${date.day}';
    return key.hashCode.abs() % 2147483647;
  }

  /// Détails de notification Android et iOS avec son, vibration et alarme Doze
  NotificationDetails _getNotificationDetails(Activity activity) {
    final androidDetails = AndroidNotificationDetails(
      'activities_reminder_channel_v2',
      'Rappels d\'activités & Alarmes exactes',
      channelDescription:
          'Notifications et alarmes exactes déclenchées à la minute près avant vos activités',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: activity.category.color,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: false,
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Planifie les notifications d'une activité pour toute la fenêtre glissante (30 jours)
  /// en prenant fidèlement en compte toutes les occurrences et exceptions de récurrence.
  Future<void> scheduleActivityNotification(Activity activity) async {
    // 1. Annulation préalable de toutes les notifications planifiées pour cette activité
    await cancelActivityNotification(activity.id);

    // 2. Si aucun rappel configuré, s'arrêter là
    if (activity.reminderMinutesBefore == null) {
      return;
    }

    final reminderMinutes = activity.reminderMinutesBefore!;
    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    final toDate = today.add(const Duration(days: slidingWindowDays));

    // 3. Calculer toutes les dates d'occurrences effectives (avec exceptions décalées / annulées / détachées)
    final occurrenceDates = RecurrenceEngine.generateOccurrences(
      startDate: activity.startDate,
      rule: activity.recurrenceRule,
      exceptions: activity.exceptions,
      fromDate: today,
      toDate: toDate,
    );

    for (final occDate in occurrenceDates) {
      // Obtenir l'activité effective pour cette date (horaires potentiellement décalés)
      final effectiveActivity = RecurrenceEngine.getOccurrenceForDate(
        activity: activity,
        targetDate: occDate,
      ) ?? activity;

      final startMinutes = effectiveActivity.startHour * 60 + effectiveActivity.startMinute;
      int scheduledTotalMinutes = startMinutes - reminderMinutes;
      int dayOffset = 0;

      if (scheduledTotalMinutes < 0) {
        // Le rappel tombe la veille
        scheduledTotalMinutes += 24 * 60;
        dayOffset = -1;
      }

      final scheduledHour = scheduledTotalMinutes ~/ 60;
      final scheduledMinute = scheduledTotalMinutes % 60;
      final notifTargetDate = occDate.add(Duration(days: dayOffset));

      final scheduledTZ = tz.TZDateTime(
        tz.local,
        notifTargetDate.year,
        notifTargetDate.month,
        notifTargetDate.day,
        scheduledHour,
        scheduledMinute,
      );

      // Programmer l'alarme uniquement si l'horaire est situé dans le futur
      if (scheduledTZ.isAfter(now)) {
        final notifId = _getOccurrenceNotificationId(activity.id, occDate);
        final body = reminderMinutes == 0
            ? 'Votre activité commence maintenant !'
            : (reminderMinutes == 1
                ? 'Débute dans 1 minute (${effectiveActivity.timeRangeFormatted})'
                : 'Débute dans $reminderMinutes min (${effectiveActivity.timeRangeFormatted})')
            + (effectiveActivity.location != null ? ' - 📍 ${effectiveActivity.location}' : '');

        try {
          await _notificationsPlugin.zonedSchedule(
            notifId,
            '⏰ ${effectiveActivity.title}',
            body,
            scheduledTZ,
            _getNotificationDetails(effectiveActivity),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: activity.id,
          );
          debugPrint(
            'Alarme exacte planifiée pour "${effectiveActivity.title}" le ${notifTargetDate.day}/${notifTargetDate.month} à ${scheduledHour}h${scheduledMinute.toString().padLeft(2, '0')}',
          );
        } catch (e) {
          debugPrint('Erreur zonedSchedule pour "${effectiveActivity.title}": $e');
        }
      }
    }
  }

  /// Annule toutes les alarmes de la fenêtre glissante pour une activité donnée
  Future<void> cancelActivityNotification(String activityId) async {
    final now = DateTime.now();
    // Parcourt les 60 jours avant et après pour nettoyer les notifications enregistrées
    for (int i = -10; i <= slidingWindowDays + 10; i++) {
      final date = now.add(Duration(days: i));
      final notifId = _getOccurrenceNotificationId(activityId, date);
      await _notificationsPlugin.cancel(notifId);
    }
  }

  /// Annule une alarme pour une occurrence précise d'une activité
  Future<void> cancelOccurrenceNotification(String activityId, DateTime date) async {
    final notifId = _getOccurrenceNotificationId(activityId, date);
    await _notificationsPlugin.cancel(notifId);
  }

  /// Annule toutes les notifications de l'application
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Replanifie l'intégralité des notifications de la fenêtre glissante pour toutes les activités
  Future<void> rescheduleAllActivities(List<Activity> activities) async {
    await cancelAllNotifications();
    for (final activity in activities) {
      if (activity.reminderMinutesBefore != null) {
        await scheduleActivityNotification(activity);
      }
    }
  }
}
