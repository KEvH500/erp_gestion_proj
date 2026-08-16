import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../models/activity.dart';

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
FormGroup buildTaskForm({Activity? existingActivity, int? defaultDayOfWeek}) {
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
      'dayOfWeek': FormControl<int>(
        value: existingActivity?.dayOfWeek ?? defaultDayOfWeek ?? DateTime.now().weekday,
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
      'isRecurring': FormControl<bool>(
        value: existingActivity?.isRecurring ?? true,
      ),
      'reminderMinutesBefore': FormControl<int?>(
        value: existingActivity?.reminderMinutesBefore,
      ),
    },
    validators: [const TimeOrderValidator()],
  );
}
