import 'package:flutter_test/flutter_test.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/recurrence_rule.dart';
import 'package:erp_gestion_proj/models/recurrence_exception.dart';
import 'package:erp_gestion_proj/services/overlap_checker.dart';

void main() {
  group('OverlapChecker - Règle de non-chevauchement des tâches', () {
    final targetMonday = DateTime(2026, 3, 9); // Lundi 9 mars 2026

    final existingNormalTask = Activity(
      id: 'task-1',
      title: 'Cours Mathématiques',
      startDate: targetMonday,
      startHour: 8,
      startMinute: 0,
      endHour: 10,
      endMinute: 0,
      category: ActivityCategory.cours,
      isLocked: false,
    );

    final existingLockedTask = Activity(
      id: 'task-locked',
      title: 'Séance révision libre',
      startDate: targetMonday,
      startHour: 14,
      startMinute: 0,
      endHour: 16,
      endMinute: 0,
      category: ActivityCategory.cours,
      isLocked: true,
    );

    test('Créneaux identiques sans verrouillage -> Bloque (Conflit bloquant)', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        isLocked: false,
        allActivities: [existingNormalTask],
      );

      expect(result.hasBlockingConflicts, isTrue);
      expect(result.blockingConflicts.length, equals(1));
      expect(result.blockingConflicts.first.id, equals('task-1'));
      expect(result.toleratedOverlaps, isEmpty);
    });

    test('Candidate verrouillée (isLocked = true) face à une tâche non verrouillée -> Toléré', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        isLocked: true,
        allActivities: [existingNormalTask],
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.toleratedOverlaps.length, equals(1));
      expect(result.toleratedOverlaps.first.id, equals('task-1'));
    });

    test('Candidate non verrouillée face à une tâche existante verrouillée -> Toléré', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 14,
        startMinute: 30,
        endHour: 15,
        endMinute: 30,
        isLocked: false,
        allActivities: [existingLockedTask],
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.toleratedOverlaps.length, equals(1));
      expect(result.toleratedOverlaps.first.id, equals('task-locked'));
    });

    test('Chevauchement partiel de 15 minutes (09h45 - 11h00 vs 08h00 - 10h00) -> Bloque', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 9,
        startMinute: 45,
        endHour: 11,
        endMinute: 0,
        isLocked: false,
        allActivities: [existingNormalTask],
      );

      expect(result.hasBlockingConflicts, isTrue);
      expect(result.blockingConflicts.first.id, equals('task-1'));
    });

    test('Créneaux contigus bord à bord (10h00 - 12h00 après 08h00 - 10h00) -> Ne bloque pas', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 10,
        startMinute: 0,
        endHour: 12,
        endMinute: 0,
        isLocked: false,
        allActivities: [existingNormalTask],
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.hasAnyOverlap, isFalse);
    });

    test('Tâches sur des jours différents -> Aucun conflit', () {
      final tuesday = DateTime(2026, 3, 10);
      final result = OverlapChecker.findOverlaps(
        targetDate: tuesday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        isLocked: false,
        allActivities: [existingNormalTask], // Existe uniquement le lundi 9 mars
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.hasAnyOverlap, isFalse);
    });

    test('Tâche récurrente hebdomadaire -> Détecte le conflit le bon jour', () {
      final weeklyTask = Activity(
        id: 'rec-1',
        title: 'Réunion Hebdo',
        startDate: DateTime(2026, 3, 2), // Lundi précédent
        startHour: 10,
        startMinute: 0,
        endHour: 11,
        endMinute: 30,
        category: ActivityCategory.travail,
        recurrenceRule: RecurrenceRule(
          id: 'rule-1',
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        ),
      );

      // Vérification sur le lundi 9 mars
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 10,
        startMinute: 30,
        endHour: 12,
        endMinute: 0,
        isLocked: false,
        allActivities: [weeklyTask],
      );

      expect(result.hasBlockingConflicts, isTrue);
      expect(result.blockingConflicts.first.id, equals('rec-1'));
    });

    test('Tâche récurrente avec exception annulée ce jour-là -> Aucun conflit', () {
      final cancelledWeeklyTask = Activity(
        id: 'rec-2',
        title: 'Sport Hebdo',
        startDate: DateTime(2026, 3, 2),
        startHour: 18,
        startMinute: 0,
        endHour: 20,
        endMinute: 0,
        category: ActivityCategory.sport,
        recurrenceRule: RecurrenceRule(
          id: 'rule-2',
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        ),
        exceptions: [
          RecurrenceException(
            taskId: 'rec-2',
            originalDate: targetMonday,
            isCancelled: true,
          ),
        ],
      );

      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 18,
        startMinute: 0,
        endHour: 19,
        endMinute: 0,
        isLocked: false,
        allActivities: [cancelledWeeklyTask],
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.hasAnyOverlap, isFalse);
    });

    test('Auto-exclusion lors de la modification de la tâche (excludeActivityId)', () {
      final result = OverlapChecker.findOverlaps(
        targetDate: targetMonday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        isLocked: false,
        allActivities: [existingNormalTask],
        excludeActivityId: 'task-1',
      );

      expect(result.hasBlockingConflicts, isFalse);
      expect(result.hasAnyOverlap, isFalse);
    });
  });
}
