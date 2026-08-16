import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/activity.dart';
import '../../services/recurrence_engine.dart';

/// Contrôleur GetX pour la gestion et génération des exports hebdomadaires
class ExportController extends BaseController {
  final currentMonday = DateTime.now().obs;
  final isLoading = false.obs;
  final isExporting = false.obs;

  /// Map des activités groupées par jour de la semaine (Lundi -> Dimanche)
  final weekActivitiesMap = <DateTime, List<Activity>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    currentMonday.value = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    loadWeekData();
  }

  /// Liste des 7 jours de la semaine courante
  List<DateTime> get daysOfWeek {
    return List.generate(
      7,
      (i) => currentMonday.value.add(Duration(days: i)),
    );
  }

  /// Titre formaté de la semaine (ex: "9 au 15 Mars 2026")
  String get weekTitleFormatted {
    final sunday = currentMonday.value.add(const Duration(days: 6));
    final startStr = DateFormat('d', 'fr_FR').format(currentMonday.value);
    final endStr = DateFormat('d MMMM yyyy', 'fr_FR').format(sunday);
    return '$startStr au $endStr';
  }

  /// Nombre total d'activités dans la semaine
  int get totalActivitiesCount {
    return weekActivitiesMap.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Passe à la semaine précédente
  void previousWeek() {
    currentMonday.value = currentMonday.value.subtract(const Duration(days: 7));
    loadWeekData();
  }

  /// Passe à la semaine suivante
  void nextWeek() {
    currentMonday.value = currentMonday.value.add(const Duration(days: 7));
    loadWeekData();
  }

  /// Revient à la semaine actuelle
  void goToCurrentWeek() {
    final now = DateTime.now();
    currentMonday.value = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    loadWeekData();
  }

  /// Charge et calcule les occurrences de la semaine avec prise en compte des exceptions
  void loadWeekData() {
    isLoading.value = true;
    try {
      final allRaw = activityRepo.getAllActivities();
      final map = <DateTime, List<Activity>>{};

      for (final day in daysOfWeek) {
        final dayList = <Activity>[];
        for (final raw in allRaw) {
          final occ = RecurrenceEngine.getOccurrenceForDate(
            activity: raw,
            targetDate: day,
          );
          if (occ != null) {
            dayList.add(occ);
          }
        }
        dayList.sort((a, b) {
          final aMin = a.startHour * 60 + a.startMinute;
          final bMin = b.startHour * 60 + b.startMinute;
          return aMin.compareTo(bMin);
        });
        map[day] = dayList;
      }

      weekActivitiesMap.assignAll(map);
    } finally {
      isLoading.value = false;
    }
  }

  /// Génère le contenu CSV de la semaine
  String generateCsvContent() {
    final rows = <List<dynamic>>[];

    // En-têtes CSV
    rows.add([
      'Jour',
      'Date',
      'Heure Debut',
      'Heure Fin',
      'Titre',
      'Categorie',
      'Lieu',
      'Verrouille',
      'Recurrent',
    ]);

    for (final day in daysOfWeek) {
      final acts = weekActivitiesMap[day] ?? [];
      final dayName = DateFormat('EEEE', 'fr_FR').format(day);
      final dateStr = DateFormat('yyyy-MM-dd').format(day);

      for (final act in acts) {
        rows.add([
          dayName[0].toUpperCase() + dayName.substring(1),
          dateStr,
          act.startTimeFormatted,
          act.endTimeFormatted,
          act.title,
          act.category.label,
          act.location ?? '',
          act.isLocked ? 'Oui' : 'Non',
          act.isRecurring ? 'Oui' : 'Non',
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Exporte et partage le fichier CSV via le système natif (SharePlus)
  Future<void> exportAndShareCsv() async {
    isExporting.value = true;
    try {
      final csvString = generateCsvContent();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'export_semaine_${DateFormat('yyyy_MM_dd').format(currentMonday.value)}.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Export Hebdomadaire - $weekTitleFormatted',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible de générer le fichier : $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// Copie un résumé textuel clair dans le presse-papier
  Future<void> copySummaryToClipboard() async {
    final buffer = StringBuffer();
    buffer.writeln('📅 EMPLOI DU TEMPS HEBDOMADAIRE');
    buffer.writeln('Semaine du $weekTitleFormatted');
    buffer.writeln('-----------------------------------');

    for (final day in daysOfWeek) {
      final acts = weekActivitiesMap[day] ?? [];
      final dayFormatted = DateFormat('EEEE d MMMM', 'fr_FR').format(day);
      buffer.writeln('\n🔹 ${dayFormatted[0].toUpperCase()}${dayFormatted.substring(1)} (${acts.length} tâches)');

      if (acts.isEmpty) {
        buffer.writeln('  (Aucune tâche)');
      } else {
        for (final act in acts) {
          final lockBadge = act.isLocked ? ' [Verrouillée]' : '';
          buffer.writeln('  • ${act.timeRangeFormatted} : ${act.title} [${act.category.label}]$lockBadge');
        }
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar(
      'Copié !',
      'Le résumé de la semaine a été copié dans le presse-papier.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
