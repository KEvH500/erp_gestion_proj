import 'package:flutter_test/flutter_test.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/recurrence_exception.dart';
import 'package:erp_gestion_proj/models/recurrence_rule.dart';
import 'package:erp_gestion_proj/services/recurrence_engine.dart';

void main() {
  group('RecurrenceEngine - Tâches ponctuelles', () {
    test('Se produit uniquement le jour de startDate', () {
      final start = DateTime(2026, 3, 10);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: null, targetDate: DateTime(2026, 3, 10)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: null, targetDate: DateTime(2026, 3, 11)), isFalse);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: null, targetDate: DateTime(2026, 3, 9)), isFalse);
    });
  });

  group('RecurrenceEngine - Quotidien (Daily)', () {
    test('Tous les jours (interval = 1)', () {
      final start = DateTime(2026, 3, 1);
      final rule = RecurrenceRule(
        id: 'r1',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 1)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 5)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 2, 28)), isFalse);
    });

    test('Tous les 2 jours (interval = 2)', () {
      final start = DateTime(2026, 3, 1);
      final rule = RecurrenceRule(
        id: 'r2',
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 1)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 2)), isFalse);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 3)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 5)), isTrue);
    });

    test('Quotidien borné par untilDate', () {
      final start = DateTime(2026, 3, 1);
      final rule = RecurrenceRule(
        id: 'r3',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endType: RecurrenceEndType.untilDate,
        untilDate: DateTime(2026, 3, 4),
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 4)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 5)), isFalse);
    });

    test('Quotidien borné par count (3 occurrences)', () {
      final start = DateTime(2026, 3, 1);
      final rule = RecurrenceRule(
        id: 'r4',
        frequency: RecurrenceFrequency.daily,
        interval: 2, // 1er mars, 3 mars, 5 mars
        endType: RecurrenceEndType.count,
        occurrenceCount: 3,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 1)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 3)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 5)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 7)), isFalse);
    });
  });

  group('RecurrenceEngine - Hebdomadaire (Weekly)', () {
    test('Chaque semaine sur un jour précis (Lundi = 1)', () {
      // 2026-03-02 est un Lundi
      final start = DateTime(2026, 3, 2);
      final rule = RecurrenceRule(
        id: 'r5',
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        byWeekDays: '1',
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 2)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 9)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 3)), isFalse);
    });

    test('Chaque semaine multi-jours (Lundi 1, Mercredi 3, Vendredi 5)', () {
      final start = DateTime(2026, 3, 2); // Lundi
      final rule = RecurrenceRule(
        id: 'r6',
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        byWeekDays: '1,3,5',
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 2)), isTrue); // Lun
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 4)), isTrue); // Mer
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 6)), isTrue); // Ven
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 3)), isFalse); // Mar
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 5)), isFalse); // Jeu
    });

    test('Toutes les 2 semaines (interval = 2)', () {
      final start = DateTime(2026, 3, 2); // Lundi semaine 1
      final rule = RecurrenceRule(
        id: 'r7',
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        byWeekDays: '1',
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 2)), isTrue); // Semaine 1
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 9)), isFalse); // Semaine 2
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 16)), isTrue); // Semaine 3
    });

    test('Hebdomadaire avec count (4 occurrences sur Lun, Ven)', () {
      // 2026-03-02 = Lun (occ 1), 2026-03-06 = Ven (occ 2), 2026-03-09 = Lun (occ 3), 2026-03-13 = Ven (occ 4)
      final start = DateTime(2026, 3, 2);
      final rule = RecurrenceRule(
        id: 'r8',
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        byWeekDays: '1,5',
        endType: RecurrenceEndType.count,
        occurrenceCount: 4,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 2)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 6)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 9)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 13)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 16)), isFalse);
    });
  });

  group('RecurrenceEngine - Mensuel (Monthly)', () {
    test('Chaque mois le 15', () {
      final start = DateTime(2026, 1, 15);
      final rule = RecurrenceRule(
        id: 'r9',
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 1, 15)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 2, 15)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 3, 15)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 2, 14)), isFalse);
    });

    test('Tous les 3 mois (interval = 3)', () {
      final start = DateTime(2026, 1, 15);
      final rule = RecurrenceRule(
        id: 'r10',
        frequency: RecurrenceFrequency.monthly,
        interval: 3,
      );

      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 1, 15)), isTrue);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 2, 15)), isFalse);
      expect(RecurrenceEngine.occursOnDate(startDate: start, rule: rule, targetDate: DateTime(2026, 4, 15)), isTrue);
    });
  });

  group('RecurrenceEngine - generateOccurrences', () {
    test('Génère la liste complète des occurrences sur une période', () {
      final start = DateTime(2026, 3, 1);
      final rule = RecurrenceRule(
        id: 'r11',
        frequency: RecurrenceFrequency.daily,
        interval: 3,
        endType: RecurrenceEndType.untilDate,
        untilDate: DateTime(2026, 3, 10),
      );

      final dates = RecurrenceEngine.generateOccurrences(
        startDate: start,
        rule: rule,
        fromDate: DateTime(2026, 3, 1),
        toDate: DateTime(2026, 3, 15),
      );

      expect(dates, [
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 4),
        DateTime(2026, 3, 7),
        DateTime(2026, 3, 10),
      ]);
    });
  });

  group('RecurrenceEngine - Exceptions de récurrence', () {
    final start = DateTime(2026, 3, 2); // Lundi
    final rule = RecurrenceRule(
      id: 'r_exc',
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      byWeekDays: '1', // Tous les Lundis : 2 mars, 9 mars, 16 mars, 23 mars
    );

    test('Occurrence annulée (isCancelled = true) est exclue', () {
      final exceptions = [
        RecurrenceException(
          taskId: 't1',
          originalDate: DateTime(2026, 3, 9), // 2e lundi annulé
          isCancelled: true,
        ),
      ];

      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 2),
      ), isTrue);

      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 9),
      ), isFalse); // Exclu

      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 16),
      ), isTrue); // Reste de la série intact
    });

    test('Occurrence détachée (isDetached = true) est exclue de la série', () {
      final exceptions = [
        RecurrenceException(
          taskId: 't1',
          originalDate: DateTime(2026, 3, 9),
          isDetached: true,
          detachedTaskId: 'detached-t1',
        ),
      ];

      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 9),
      ), isFalse);
    });

    test('Occurrence déplacée à une autre date (ex: Mardi 10 mars au lieu du Lundi 9 mars)', () {
      final exceptions = [
        RecurrenceException(
          taskId: 't1',
          originalDate: DateTime(2026, 3, 9),
          newDate: DateTime(2026, 3, 10), // Déplacé au mardi
          newStartHour: 10,
          newStartMinute: 30,
        ),
      ];

      // Lundi 9 mars : n'apparaît plus
      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 9),
      ), isFalse);

      // Mardi 10 mars : apparaît bien
      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 10),
      ), isTrue);

      // Lundi 16 mars : reste intact
      expect(RecurrenceEngine.occursOnDate(
        startDate: start,
        rule: rule,
        exceptions: exceptions,
        targetDate: DateTime(2026, 3, 16),
      ), isTrue);
    });

    test('getOccurrenceForDate applique les nouveaux horaires', () {
      final activity = Activity(
        id: 'act-1',
        title: 'Cours de Maths',
        startDate: start,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        category: ActivityCategory.cours,
        recurrenceRule: rule,
        exceptions: [
          RecurrenceException(
            taskId: 'act-1',
            originalDate: DateTime(2026, 3, 9),
            newDate: DateTime(2026, 3, 10),
            newStartHour: 14,
            newStartMinute: 30,
            newEndHour: 16,
            newEndMinute: 30,
          ),
        ],
      );

      // Le 9 mars : null
      final occ9 = RecurrenceEngine.getOccurrenceForDate(
        activity: activity,
        targetDate: DateTime(2026, 3, 9),
      );
      expect(occ9, isNull);

      // Le 10 mars : horaires surchargés
      final occ10 = RecurrenceEngine.getOccurrenceForDate(
        activity: activity,
        targetDate: DateTime(2026, 3, 10),
      );
      expect(occ10, isNotNull);
      expect(occ10!.startHour, 14);
      expect(occ10.startMinute, 30);
      expect(occ10.endHour, 16);
      expect(occ10.endMinute, 30);
      expect(occ10.startDate, DateTime(2026, 3, 10));

      // Le 16 mars : horaires d'origine conservés
      final occ16 = RecurrenceEngine.getOccurrenceForDate(
        activity: activity,
        targetDate: DateTime(2026, 3, 16),
      );
      expect(occ16, isNotNull);
      expect(occ16!.startHour, 8);
      expect(occ16.startMinute, 0);
      expect(occ16.endHour, 10);
      expect(occ16.endMinute, 0);
    });
  });
}
