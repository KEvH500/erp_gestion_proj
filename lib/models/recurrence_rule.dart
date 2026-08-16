import 'package:hive/hive.dart';

part 'recurrence_rule.g.dart';

@HiveType(typeId: 7)
enum RecurrenceFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,
}

extension RecurrenceFrequencyExtension on RecurrenceFrequency {
  String get label {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Chaque jour';
      case RecurrenceFrequency.weekly:
        return 'Chaque semaine';
      case RecurrenceFrequency.monthly:
        return 'Chaque mois';
    }
  }
}

@HiveType(typeId: 8)
enum RecurrenceEndType {
  @HiveField(0)
  never,

  @HiveField(1)
  untilDate,

  @HiveField(2)
  count,
}

extension RecurrenceEndTypeExtension on RecurrenceEndType {
  String get label {
    switch (this) {
      case RecurrenceEndType.never:
        return 'Jamais';
      case RecurrenceEndType.untilDate:
        return 'Jusqu\'à une date';
      case RecurrenceEndType.count:
        return 'Après un nombre de fois';
    }
  }
}

@HiveType(typeId: 9)
class RecurrenceRule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final RecurrenceFrequency frequency;

  @HiveField(2)
  final int interval; // ex: 1 = chaque, 2 = tous les 2, etc.

  @HiveField(3)
  final String? byWeekDays; // Sérialisé en chaîne "1,3,5" pour Lun, Mer, Ven

  @HiveField(4)
  final RecurrenceEndType endType;

  @HiveField(5)
  final DateTime? untilDate;

  @HiveField(6)
  final int? occurrenceCount;

  RecurrenceRule({
    required this.id,
    required this.frequency,
    this.interval = 1,
    this.byWeekDays,
    this.endType = RecurrenceEndType.never,
    this.untilDate,
    this.occurrenceCount,
  });

  /// Liste des jours de la semaine (1 = Lundi, 7 = Dimanche)
  List<int> get weekDaysList {
    if (byWeekDays == null || byWeekDays!.trim().isEmpty) {
      return const [];
    }
    return byWeekDays!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }

  /// Description textuelle conviviale de la récurrence
  String get humanReadableDescription {
    final buffer = StringBuffer();

    switch (frequency) {
      case RecurrenceFrequency.daily:
        if (interval == 1) {
          buffer.write('Tous les jours');
        } else {
          buffer.write('Tous les $interval jours');
        }
        break;
      case RecurrenceFrequency.weekly:
        if (interval == 1) {
          buffer.write('Toutes les semaines');
        } else {
          buffer.write('Toutes les $interval semaines');
        }
        final days = weekDaysList;
        if (days.isNotEmpty) {
          final dayNames = days.map((d) {
            switch (d) {
              case 1:
                return 'Lun';
              case 2:
                return 'Mar';
              case 3:
                return 'Mer';
              case 4:
                return 'Jeu';
              case 5:
                return 'Ven';
              case 6:
                return 'Sam';
              case 7:
                return 'Dim';
              default:
                return '';
            }
          }).join(', ');
          buffer.write(' ($dayNames)');
        }
        break;
      case RecurrenceFrequency.monthly:
        if (interval == 1) {
          buffer.write('Tous les mois');
        } else {
          buffer.write('Tous les $interval mois');
        }
        break;
    }

    switch (endType) {
      case RecurrenceEndType.never:
        break;
      case RecurrenceEndType.untilDate:
        if (untilDate != null) {
          final d = untilDate!;
          buffer.write(', jusqu\'au ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
        }
        break;
      case RecurrenceEndType.count:
        if (occurrenceCount != null) {
          buffer.write(', $occurrenceCount fois');
        }
        break;
    }

    return buffer.toString();
  }

  RecurrenceRule copyWith({
    String? id,
    RecurrenceFrequency? frequency,
    int? interval,
    String? byWeekDays,
    RecurrenceEndType? endType,
    DateTime? untilDate,
    int? occurrenceCount,
  }) {
    return RecurrenceRule(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      byWeekDays: byWeekDays ?? this.byWeekDays,
      endType: endType ?? this.endType,
      untilDate: untilDate ?? this.untilDate,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceRule &&
        other.id == id &&
        other.frequency == frequency &&
        other.interval == interval &&
        other.byWeekDays == byWeekDays &&
        other.endType == endType &&
        other.untilDate == untilDate &&
        other.occurrenceCount == occurrenceCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      frequency,
      interval,
      byWeekDays,
      endType,
      untilDate,
      occurrenceCount,
    );
  }
}
