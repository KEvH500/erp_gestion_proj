import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'recurrence_exception.g.dart';

@HiveType(typeId: 10)
class RecurrenceException extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime originalDate; // Date normalisée (y, m, d) de l'occurrence d'origine

  @HiveField(3)
  final bool isCancelled;

  @HiveField(4)
  final bool isDetached;

  @HiveField(5)
  final String? detachedTaskId;

  @HiveField(6)
  final DateTime? newDate;

  @HiveField(7)
  final DateTime? newStartTime;

  @HiveField(8)
  final DateTime? newEndTime;

  @HiveField(9)
  final int? newStartHour;

  @HiveField(10)
  final int? newStartMinute;

  @HiveField(11)
  final int? newEndHour;

  @HiveField(12)
  final int? newEndMinute;

  RecurrenceException({
    this.id,
    required this.taskId,
    required DateTime originalDate,
    this.isCancelled = false,
    this.isDetached = false,
    this.detachedTaskId,
    this.newDate,
    this.newStartTime,
    this.newEndTime,
    this.newStartHour,
    this.newStartMinute,
    this.newEndHour,
    this.newEndMinute,
  }) : originalDate = DateTime(
          originalDate.year,
          originalDate.month,
          originalDate.day,
        );

  /// Helper pour obtenir l'heure de début effective
  int? get effectiveStartHour => newStartHour ?? newStartTime?.hour;
  int? get effectiveStartMinute => newStartMinute ?? newStartTime?.minute;
  int? get effectiveEndHour => newEndHour ?? newEndTime?.hour;
  int? get effectiveEndMinute => newEndMinute ?? newEndTime?.minute;

  /// Helper pour obtenir la date effective
  DateTime? get effectiveDate => newDate != null
      ? DateTime(newDate!.year, newDate!.month, newDate!.day)
      : (newStartTime != null
          ? DateTime(newStartTime!.year, newStartTime!.month, newStartTime!.day)
          : null);

  RecurrenceException copyWith({
    String? id,
    String? taskId,
    DateTime? originalDate,
    bool? isCancelled,
    bool? isDetached,
    String? detachedTaskId,
    DateTime? newDate,
    DateTime? newStartTime,
    DateTime? newEndTime,
    int? newStartHour,
    int? newStartMinute,
    int? newEndHour,
    int? newEndMinute,
  }) {
    return RecurrenceException(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      originalDate: originalDate ?? this.originalDate,
      isCancelled: isCancelled ?? this.isCancelled,
      isDetached: isDetached ?? this.isDetached,
      detachedTaskId: detachedTaskId ?? this.detachedTaskId,
      newDate: newDate ?? this.newDate,
      newStartTime: newStartTime ?? this.newStartTime,
      newEndTime: newEndTime ?? this.newEndTime,
      newStartHour: newStartHour ?? this.newStartHour,
      newStartMinute: newStartMinute ?? this.newStartMinute,
      newEndHour: newEndHour ?? this.newEndHour,
      newEndMinute: newEndMinute ?? this.newEndMinute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceException &&
        other.id == id &&
        other.taskId == taskId &&
        other.originalDate.year == originalDate.year &&
        other.originalDate.month == originalDate.month &&
        other.originalDate.day == originalDate.day &&
        other.isCancelled == isCancelled &&
        other.isDetached == isDetached &&
        other.detachedTaskId == detachedTaskId &&
        other.newDate == newDate &&
        other.newStartTime == newStartTime &&
        other.newEndTime == newEndTime &&
        other.newStartHour == newStartHour &&
        other.newStartMinute == newStartMinute &&
        other.newEndHour == newEndHour &&
        other.newEndMinute == newEndMinute;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      taskId,
      originalDate,
      isCancelled,
      isDetached,
      detachedTaskId,
      newDate,
      newStartTime,
      newEndTime,
      newStartHour,
      newStartMinute,
      newEndHour,
      newEndMinute,
    );
  }
}
