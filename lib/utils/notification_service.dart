import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialisation du plugin de notifications locales
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialisation des fuseaux horaires pour la planification
    tz.initializeTimeZones();
    // Utilise le fuseau horaire local par défaut
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    } catch (_) {
      // Si la localisation spécifique échoue, repli sur UTC
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    _isInitialized = true;
  }

  /// Demande des permissions de notification pour Android 13+ et iOS
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

  /// Génère un identifiant entier 32-bit unique et déterministe à partir de l'UUID
  int _getNotificationId(String activityId) {
    return activityId.hashCode.abs() % 2147483647;
  }

  /// Détails de notification pour Android et iOS
  NotificationDetails _getNotificationDetails(Activity activity) {
    final androidDetails = AndroidNotificationDetails(
      'activities_reminder_channel',
      'Rappels d\'activités',
      channelDescription:
          'Notifications de rappel avant vos cours et activités programmées',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: activity.category.color,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Planifie une notification locale pour une activité
  Future<void> scheduleActivityNotification(Activity activity) async {
    if (activity.reminderMinutesBefore == null) {
      // Aucun rappel configuré : on s'assure d'annuler une éventuelle notification résiduelle
      await cancelActivityNotification(activity.id);
      return;
    }

    // Annule d'abord toute notification existante pour cette activité pour éviter les doublons
    await cancelActivityNotification(activity.id);

    final notificationId = _getNotificationId(activity.id);

    // Calcul de l'heure exacte de la notification (début - X minutes)
    final reminderMinutes = activity.reminderMinutesBefore!;
    final totalStartMinutes = activity.startHour * 60 + activity.startMinute;
    int scheduledTotalMinutes = totalStartMinutes - reminderMinutes;

    int targetDayOfWeek = activity.dayOfWeek;
    if (scheduledTotalMinutes < 0) {
      // Le rappel tombe la veille
      scheduledTotalMinutes += 24 * 60;
      targetDayOfWeek = (activity.dayOfWeek == 1) ? 7 : activity.dayOfWeek - 1;
    }

    final scheduledHour = scheduledTotalMinutes ~/ 60;
    final scheduledMinute = scheduledTotalMinutes % 60;

    // Calcul de la prochaine occurrence
    final scheduledDate = _nextInstanceOfDayAndTime(
      targetDayOfWeek,
      scheduledHour,
      scheduledMinute,
    );

    final body = reminderMinutes == 0
        ? 'Votre activité commence maintenant !'
        : 'Débute dans $reminderMinutes min (${activity.timeRangeFormatted})'
            '${activity.location != null ? ' - 📍 ${activity.location}' : ''}';

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ ${activity.title}',
        body,
        scheduledDate,
        _getNotificationDetails(activity),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: activity.isRecurring
            ? DateTimeComponents.dayOfWeekAndTime // Répétition hebdomadaire automatique
            : DateTimeComponents.time,
        payload: activity.id,
      );
      debugPrint(
        'Notification planifiée pour "${activity.title}" le jour $targetDayOfWeek à ${scheduledHour}h${scheduledMinute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      debugPrint('Erreur lors de la planification de notification: $e');
    }
  }

  /// Annule la notification liée à une activité
  Future<void> cancelActivityNotification(String activityId) async {
    final notificationId = _getNotificationId(activityId);
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('Notification annulée pour l\'activité ID: $activityId');
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Replanifie les notifications pour toute une liste d'activités
  Future<void> rescheduleAllActivities(List<Activity> activities) async {
    await cancelAllNotifications();
    for (final activity in activities) {
      if (activity.reminderMinutesBefore != null) {
        await scheduleActivityNotification(activity);
      }
    }
  }

  /// Calcule la prochaine instance d'un jour donné (1=Lun ... 7=Dim) à une heure et minute précises
  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Ajuste le jour de la semaine (DateTime.monday = 1 ... DateTime.sunday = 7)
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Si la date calculée est déjà passée aujourd'hui, on passe à la semaine suivante
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
}
