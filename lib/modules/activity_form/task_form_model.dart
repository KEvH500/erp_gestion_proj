import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../models/activity.dart';
import '../../models/recurrence_rule.dart';

/// Validateur personnalisé multi-champs vérifiant que l'heure de fin est après l'heure de début
class TimeOrderValidator extends Validator<dynamic> {
  const TimeOrderValidator() : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final form = control as FormGroup;
    final startControl = form.control('startTime') as FormControl<TimeOfDay>;
    final endControl = form.control('endTime') as FormControl<TimeOfDay>;

    final startTime = startControl.value;
    final endTime = endControl.value;

    if (startTime != null && endTime != null) {
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      if (endMinutes <= startMinutes) {
        endControl.setErrors({'timeOrder': true});
        return {'timeOrder': true};
      } else {
        endControl.removeError('timeOrder');
      }
    }

    return null;
  }
}

/// Usine de création du FormGroup pour le formulaire d'activité / tâche
FormGroup buildTaskForm({
  Activity? existingActivity,
  DateTime? defaultStartDate,
  int? defaultDayOfWeek,
}) {
  DateTime initialStartDate = existingActivity?.startDate ?? defaultStartDate ?? DateTime.now();
  if (existingActivity == null && defaultStartDate == null && defaultDayOfWeek != null) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    initialStartDate = currentMonday.add(Duration(days: defaultDayOfWeek - 1));
  }

  return FormGroup(
    {
      'title': FormControl<String>(
        value: existingActivity?.title ?? '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'description': FormControl<String>(
        value: existingActivity?.description ?? '',
      ),
      'location': FormControl<String>(
        value: existingActivity?.location ?? '',
      ),
      'startDate': FormControl<DateTime>(
        value: initialStartDate,
        validators: [Validators.required],
      ),
      'startTime': FormControl<TimeOfDay>(
        value: existingActivity != null
            ? TimeOfDay(
                hour: existingActivity.startHour,
                minute: existingActivity.startMinute,
              )
            : const TimeOfDay(hour: 8, minute: 0),
        validators: [Validators.required],
      ),
      'endTime': FormControl<TimeOfDay>(
        value: existingActivity != null
            ? TimeOfDay(
                hour: existingActivity.endHour,
                minute: existingActivity.endMinute,
              )
            : const TimeOfDay(hour: 9, minute: 30),
        validators: [Validators.required],
      ),
      'category': FormControl<ActivityCategory>(
        value: existingActivity?.category ?? ActivityCategory.cours,
        validators: [Validators.required],
      ),
      'reminderMinutesBefore': FormControl<int?>(
        value: existingActivity?.reminderMinutesBefore,
      ),

      // Configuration de récurrence généralisée
      'isRecurring': FormControl<bool>(
        value: existingActivity?.isRecurring ?? false,
      ),
      'recurrenceFrequency': FormControl<RecurrenceFrequency>(
        value: existingActivity?.recurrenceRule?.frequency ?? RecurrenceFrequency.weekly,
      ),
      'recurrenceInterval': FormControl<int>(
        value: existingActivity?.recurrenceRule?.interval ?? 1,
        validators: [Validators.required, Validators.min(1)],
      ),
      'recurrenceWeekDays': FormControl<List<int>>(
        value: existingActivity?.recurrenceRule?.weekDaysList ?? [initialStartDate.weekday],
      ),
      'recurrenceEndType': FormControl<RecurrenceEndType>(
        value: existingActivity?.recurrenceRule?.endType ?? RecurrenceEndType.never,
      ),
      'recurrenceUntilDate': FormControl<DateTime?>(
        value: existingActivity?.recurrenceRule?.untilDate ??
            initialStartDate.add(const Duration(days: 30)),
      ),
      'recurrenceCount': FormControl<int?>(
        value: existingActivity?.recurrenceRule?.occurrenceCount ?? 10,
      ),

      // Verrouillage / Autorisation de chevauchement
      'isLocked': FormControl<bool>(
        value: existingActivity?.isLocked ?? false,
      ),
    },
    validators: [const TimeOrderValidator()],
  );
}
