import '../models/activity.dart';
import 'recurrence_engine.dart';

/// Résultat détaillé d'un contrôle de chevauchement d'horaires
class OverlapCheckResult {
  /// Conflits stricts (aucune des deux tâches n'est verrouillée) -> Bloque l'enregistrement
  final List<Activity> blockingConflicts;

  /// Chevauchements tolérés (au moins l'une des tâches a `isLocked = true`) -> Informatif
  final List<Activity> toleratedOverlaps;

  const OverlapCheckResult({
    this.blockingConflicts = const [],
    this.toleratedOverlaps = const [],
  });

  /// Indique s'il y a au moins un conflit qui doit bloquer la sauvegarde
  bool get hasBlockingConflicts => blockingConflicts.isNotEmpty;

  /// Indique s'il y a un quelconque chevauchement (bloquant ou toléré)
  bool get hasAnyOverlap => blockingConflicts.isNotEmpty || toleratedOverlaps.isNotEmpty;
}

/// Service pur de vérification de non-chevauchement des créneaux horaires
class OverlapChecker {
  /// Vérifie si deux plages horaires définies en minutes depuis minuit se chevauchent.
  /// Formule standard : start1 < end2 AND start2 < end1
  static bool doTimeSlotsOverlap({
    required int startMinutes1,
    required int endMinutes1,
    required int startMinutes2,
    required int endMinutes2,
  }) {
    return startMinutes1 < endMinutes2 && startMinutes2 < endMinutes1;
  }

  /// Vérifie les conflits pour une tâche candidate sur une date précise
  /// par rapport à une liste d'activités existantes (avec calcul d'occurrences réelles).
  static OverlapCheckResult findOverlaps({
    required DateTime targetDate,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required bool isLocked,
    required List<Activity> allActivities,
    String? excludeActivityId,
  }) {
    final candidateStart = startHour * 60 + startMinute;
    final candidateEnd = endHour * 60 + endMinute;

    final blocking = <Activity>[];
    final tolerated = <Activity>[];

    for (final rawActivity in allActivities) {
      // Exclure la tâche en cours d'édition
      if (excludeActivityId != null && rawActivity.id == excludeActivityId) {
        continue;
      }

      // Calculer l'occurrence réelle de cette activité pour la date cible
      final occurrence = RecurrenceEngine.getOccurrenceForDate(
        activity: rawActivity,
        targetDate: targetDate,
      );

      // Si l'activité n'a pas d'occurrence ce jour-là (ou annulée/archivée), ignorer
      if (occurrence == null) {
        continue;
      }

      final existingStart = occurrence.startHour * 60 + occurrence.startMinute;
      final existingEnd = occurrence.endHour * 60 + occurrence.endMinute;

      final overlaps = doTimeSlotsOverlap(
        startMinutes1: candidateStart,
        endMinutes1: candidateEnd,
        startMinutes2: existingStart,
        endMinutes2: existingEnd,
      );

      if (overlaps) {
        // Règle de verrouillage par paire :
        // Si la tâche candidate OU la tâche existante est verrouillée, le chevauchement est toléré
        if (isLocked || occurrence.isLocked) {
          tolerated.add(occurrence);
        } else {
          blocking.add(occurrence);
        }
      }
    }

    return OverlapCheckResult(
      blockingConflicts: blocking,
      toleratedOverlaps: tolerated,
    );
  }
}
