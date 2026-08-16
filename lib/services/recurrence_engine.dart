import '../models/activity.dart';
import '../models/recurrence_exception.dart';
import '../models/recurrence_rule.dart';

/// Moteur de calcul et d'évaluation des règles de récurrence temporelle et d'application des exceptions
class RecurrenceEngine {
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Évalue si la règle de base (brute) produit une occurrence à `targetDate`.
  static bool rawOccursOnDate({
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

  /// Détermine si un événement avec une `startDate`, une `rule` optionnelle et une liste d'`exceptions`
  /// se produit effectivement à la date `targetDate`.
  static bool occursOnDate({
    required DateTime startDate,
    required RecurrenceRule? rule,
    List<RecurrenceException> exceptions = const [],
    required DateTime targetDate,
  }) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    // 1. Vérifier si une exception a déplacé une occurrence vers cette date cible
    for (final exc in exceptions) {
      if (exc.isCancelled || exc.isDetached) continue;
      if (exc.effectiveDate != null && _isSameDay(exc.effectiveDate!, target)) {
        return true;
      }
    }

    // 2. Vérifier si la date cible est une occurrence brute du modèle
    if (!rawOccursOnDate(startDate: startDate, rule: rule, targetDate: target)) {
      return false;
    }

    // 3. Si la date cible est une occurrence brute, vérifier s'il existe une exception pour son originalDate
    for (final exc in exceptions) {
      if (_isSameDay(exc.originalDate, target)) {
        // Si l'occurrence est annulée ou détachée, elle ne doit plus apparaître dans la série
        if (exc.isCancelled || exc.isDetached) {
          return false;
        }
        // Si l'occurrence a été déplacée vers un autre jour, elle ne se produit plus à la date d'origine
        if (exc.effectiveDate != null && !_isSameDay(exc.effectiveDate!, target)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Calcule l'instance effective d'une activité pour une date cible en appliquant les exceptions d'horaires/dates.
  /// Retourne `null` si l'activité ne se produit pas à `targetDate` (annulée, détachée ou déplacée ailleurs).
  static Activity? getOccurrenceForDate({
    required Activity activity,
    required DateTime targetDate,
  }) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (!occursOnDate(
      startDate: activity.startDate,
      rule: activity.recurrenceRule,
      exceptions: activity.exceptions,
      targetDate: target,
    )) {
      return null;
    }

    // Chercher l'exception qui s'applique à cette occurrence sur targetDate
    RecurrenceException? appliedException;

    for (final exc in activity.exceptions) {
      if (exc.isCancelled || exc.isDetached) continue;
      // Cas 1 : Déplacée vers cette targetDate
      if (exc.effectiveDate != null && _isSameDay(exc.effectiveDate!, target)) {
        appliedException = exc;
        break;
      }
      // Cas 2 : Occurrence originale à cette targetDate (ex: horaires modifiés le même jour)
      if (_isSameDay(exc.originalDate, target) &&
          (exc.effectiveDate == null || _isSameDay(exc.effectiveDate!, target))) {
        appliedException = exc;
        break;
      }
    }

    if (appliedException != null) {
      final newStartH = appliedException.effectiveStartHour ?? activity.startHour;
      final newStartM = appliedException.effectiveStartMinute ?? activity.startMinute;
      final newEndH = appliedException.effectiveEndHour ?? activity.endHour;
      final newEndM = appliedException.effectiveEndMinute ?? activity.endMinute;

      return activity.copyWith(
        startDate: target,
        startHour: newStartH,
        startMinute: newStartM,
        endHour: newEndH,
        endMinute: newEndM,
      );
    }

    return activity.copyWith(startDate: target);
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

  /// Génère toutes les dates d'occurrence effectives comprises dans l'intervalle [fromDate, toDate]
  static List<DateTime> generateOccurrences({
    required DateTime startDate,
    required RecurrenceRule? rule,
    List<RecurrenceException> exceptions = const [],
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
      if (occursOnDate(
        startDate: startDate,
        rule: rule,
        exceptions: exceptions,
        targetDate: current,
      )) {
        results.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return results;
  }
}
