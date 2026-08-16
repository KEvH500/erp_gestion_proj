import 'package:intl/intl.dart';
import 'activity.dart';

/// Modèle représentant la synthèse analytique d'un rapport de fin de journée
class DailyReport {
  final DateTime date;
  final int activitiesTotal;
  final int activitiesCompleted;
  final int plannedDurationMinutes;
  final int completedDurationMinutes;
  final int unplannedTasksTotal;
  final int unplannedTasksCompleted;
  final int goalsTotal;
  final int goalsAchieved;
  final Map<ActivityCategory, int> categoryDurationMinutes;
  final int score; // Score global sur 100
  final String appreciation;
  final String? personalNotes;
  final DateTime generatedAt;

  DailyReport({
    required this.date,
    required this.activitiesTotal,
    required this.activitiesCompleted,
    required this.plannedDurationMinutes,
    required this.completedDurationMinutes,
    required this.unplannedTasksTotal,
    required this.unplannedTasksCompleted,
    required this.goalsTotal,
    required this.goalsAchieved,
    required this.categoryDurationMinutes,
    required this.score,
    required this.appreciation,
    this.personalNotes,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  DailyReport copyWith({
    DateTime? date,
    int? activitiesTotal,
    int? activitiesCompleted,
    int? plannedDurationMinutes,
    int? completedDurationMinutes,
    int? unplannedTasksTotal,
    int? unplannedTasksCompleted,
    int? goalsTotal,
    int? goalsAchieved,
    Map<ActivityCategory, int>? categoryDurationMinutes,
    int? score,
    String? appreciation,
    String? personalNotes,
    DateTime? generatedAt,
  }) {
    return DailyReport(
      date: date ?? this.date,
      activitiesTotal: activitiesTotal ?? this.activitiesTotal,
      activitiesCompleted: activitiesCompleted ?? this.activitiesCompleted,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      completedDurationMinutes: completedDurationMinutes ?? this.completedDurationMinutes,
      unplannedTasksTotal: unplannedTasksTotal ?? this.unplannedTasksTotal,
      unplannedTasksCompleted: unplannedTasksCompleted ?? this.unplannedTasksCompleted,
      goalsTotal: goalsTotal ?? this.goalsTotal,
      goalsAchieved: goalsAchieved ?? this.goalsAchieved,
      categoryDurationMinutes: categoryDurationMinutes ?? this.categoryDurationMinutes,
      score: score ?? this.score,
      appreciation: appreciation ?? this.appreciation,
      personalNotes: personalNotes ?? this.personalNotes,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Taux de réalisation des activités planifiées
  double get activityCompletionRate =>
      activitiesTotal > 0 ? (activitiesCompleted / activitiesTotal) : 1.0;

  /// Taux de résolution des imprévus
  double get unplannedResolutionRate =>
      unplannedTasksTotal > 0 ? (unplannedTasksCompleted / unplannedTasksTotal) : 1.0;

  /// Taux de succès des objectifs
  double get goalSuccessRate =>
      goalsTotal > 0 ? (goalsAchieved / goalsTotal) : 1.0;

  /// Temps total passé en format heures & minutes (ex: "6h 30m")
  String get totalCompletedTimeFormatted {
    final h = completedDurationMinutes ~/ 60;
    final m = completedDurationMinutes % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m';
  }

  /// Temps total planifié en format heures & minutes
  String get totalPlannedTimeFormatted {
    final h = plannedDurationMinutes ~/ 60;
    final m = plannedDurationMinutes % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m';
  }

  /// Génère un texte de rapport complet et propre pour le partage / copier-coller
  String toFormattedText() {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

    final buffer = StringBuffer();
    buffer.writeln('📊 **RAPPORT DE FIN DE JOURNÉE**');
    buffer.writeln('📅 $capitalizedDate');
    buffer.writeln('⭐ Score de performance : $score / 100 — $appreciation');
    buffer.writeln('──────────────────────────────');

    buffer.writeln('\n🎯 **OBJECTIFS**');
    buffer.writeln('• $goalsAchieved / $goalsTotal objectif(s) atteint(s) (${(goalSuccessRate * 100).toInt()}%)');

    buffer.writeln('\n📅 **EMPLOI DU TEMPS & ACTIVITÉS**');
    buffer.writeln('• Réalisées : $activitiesCompleted / $activitiesTotal activités');
    buffer.writeln('• Temps effectif : $totalCompletedTimeFormatted / $totalPlannedTimeFormatted planifié');

    buffer.writeln('\n⚡ **IMPRÉVUS & URGENCES**');
    buffer.writeln('• Résolus : $unplannedTasksCompleted / $unplannedTasksTotal imprévu(s)');

    if (categoryDurationMinutes.isNotEmpty) {
      buffer.writeln('\n⏱️ **RÉPARTITION DU TEMPS**');
      categoryDurationMinutes.forEach((cat, mins) {
        if (mins > 0) {
          final h = mins ~/ 60;
          final m = mins % 60;
          final timeStr = h > 0 ? '${h}h${m > 0 ? "${m}m" : ""}' : '${m}m';
          buffer.writeln('• ${cat.label} : $timeStr');
        }
      });
    }

    if (personalNotes != null && personalNotes!.trim().isNotEmpty) {
      buffer.writeln('\n📝 **BILAN PERSONNEL**');
      buffer.writeln(personalNotes!.trim());
    }

    buffer.writeln('\n──────────────────────────────');
    buffer.writeln('Généré avec succès via ERP Gestion Proj 🚀');

    return buffer.toString();
  }
}
