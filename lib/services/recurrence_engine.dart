import '../models/recurrence_rule.dart';

/// Moteur de calcul et d'évaluation des règles de récurrence temporelle
class RecurrenceEngine {
  /// Détermine si un événement avec une `startDate` et une `rule` optionnelle se produit à la date `targetDate`.
  static bool occursOnDate({
    required DateTime startDate,
    required RecurrenceRule? rule,
    required DateTime targetDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    // 1. Une tâche ne peut jamais se produire avant sa date de début
    if (target.isBefore(start)) {
      return false;
    }

    // 2. Tâche ponctuelle (pas de règle)
    if (rule == null) {
      return target.isAtSameMomentAs(start);
    }

    // 3. Condition de fin par date
    if (rule.endType == RecurrenceEndType.untilDate && rule.untilDate != null) {
      final until = DateTime(
        rule.untilDate!.year,
        rule.untilDate!.month,
        rule.untilDate!.day,
      );
      if (target.isAfter(until)) {
        return false;
      }
    }

    final interval = rule.interval > 0 ? rule.interval : 1;

    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        final deltaDays = target.difference(start).inDays;
        if (deltaDays < 0 || deltaDays % interval != 0) {
          return false;
        }

        if (rule.endType == RecurrenceEndType.count && rule.occurrenceCount != null) {
          final count = (deltaDays ~/ interval) + 1;
          if (count > rule.occurrenceCount!) {
            return false;
          }
        }
        return true;

      case RecurrenceFrequency.weekly:
        final targetWeekDay = target.weekday;
        final targetDays = rule.weekDaysList.isNotEmpty
            ? rule.weekDaysList
            : [start.weekday];

        if (!targetDays.contains(targetWeekDay)) {
          return false;
        }

        // Calcul du delta de semaines complètes depuis le lundi de début
        final mondayStart = start.subtract(Duration(days: start.weekday - 1));
        final mondayTarget = target.subtract(Duration(days: target.weekday - 1));
        final deltaWeeks = mondayTarget.difference(mondayStart).inDays ~/ 7;

        if (deltaWeeks < 0 || deltaWeeks % interval != 0) {
          return false;
        }

        // Condition de fin par nombre d'occurrences
        if (rule.endType == RecurrenceEndType.count && rule.occurrenceCount != null) {
          final rank = _calculateWeeklyOccurrenceRank(
            start: start,
            target: target,
            days: targetDays,
            interval: interval,
          );
          if (rank > rule.occurrenceCount!) {
            return false;
          }
        }

        return true;

      case RecurrenceFrequency.monthly:
        // Correspondance au même jour du mois (ex: le 15)
        if (target.day != start.day) {
          return false;
        }

        final deltaMonths = (target.year - start.year) * 12 + (target.month - start.month);
        if (deltaMonths < 0 || deltaMonths % interval != 0) {
          return false;
        }

        if (rule.endType == RecurrenceEndType.count && rule.occurrenceCount != null) {
          final count = (deltaMonths ~/ interval) + 1;
          if (count > rule.occurrenceCount!) {
            return false;
          }
        }
        return true;
    }
  }

  /// Calcule le rang d'une occurrence hebdomadaire (multi-jours possible)
  static int _calculateWeeklyOccurrenceRank({
    required DateTime start,
    required DateTime target,
    required List<int> days,
    required int interval,
  }) {
    final sortedDays = List<int>.from(days)..sort();
    int count = 0;

    final mondayStart = start.subtract(Duration(days: start.weekday - 1));
    final mondayTarget = target.subtract(Duration(days: target.weekday - 1));
    final totalWeeks = mondayTarget.difference(mondayStart).inDays ~/ 7;

    for (int w = 0; w <= totalWeeks; w += interval) {
      final currentMonday = mondayStart.add(Duration(days: w * 7));
      for (final dayOfWeek in sortedDays) {
        final currentDate = currentMonday.add(Duration(days: dayOfWeek - 1));
        if (currentDate.isBefore(start)) {
          continue; // Avant le début réel de la première occurrence
        }
        if (currentDate.isAfter(target)) {
          break;
        }
        count++;
      }
    }

    return count;
  }

  /// Génère toutes les dates d'occurrence comprises dans l'intervalle [fromDate, toDate]
  static List<DateTime> generateOccurrences({
    required DateTime startDate,
    required RecurrenceRule? rule,
    required DateTime fromDate,
    required DateTime toDate,
    int maxLimit = 500,
  }) {
    final results = <DateTime>[];
    final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final to = DateTime(toDate.year, toDate.month, toDate.day);

    if (to.isBefore(from)) return results;

    DateTime current = from;
    while (!current.isAfter(to) && results.length < maxLimit) {
      if (occursOnDate(startDate: startDate, rule: rule, targetDate: current)) {
        results.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return results;
  }
}
