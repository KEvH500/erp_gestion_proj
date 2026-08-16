import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/activity.dart';
import 'task_form_model.dart';

/// Contrôleur GetX pour le formulaire d'activité / tâche utilisant reactive_forms
class ActivityFormController extends BaseController {
  late final FormGroup form;

  final isEditing = false.obs;
  final isSaving = false.obs;
  Activity? existingActivity;

  // Jours et options de rappel réactifs chargés dynamiquement depuis SQLite
  final days = <Map<String, dynamic>>[].obs;
  final reminderOptions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initForm();
    loadConfigFromSqlite();
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }

  void _initForm() {
    int? defaultDay;
    if (Get.parameters.containsKey('day')) {
      final dayParam = int.tryParse(Get.parameters['day'] ?? '1');
      if (dayParam != null && dayParam >= 1 && dayParam <= 7) {
        defaultDay = dayParam;
      }
    }

    if (Get.arguments is Activity) {
      existingActivity = Get.arguments as Activity;
      isEditing.value = true;
    }

    form = buildTaskForm(
      existingActivity: existingActivity,
      defaultDayOfWeek: defaultDay,
    );
  }

  Future<void> loadConfigFromSqlite() async {
    try {
      final activeDays = await configRepo.getActiveDays();
      if (activeDays.isNotEmpty) {
        days.assignAll(activeDays);
      } else {
        days.assignAll(const [
          {'value': 1, 'label': 'Lundi'},
          {'value': 2, 'label': 'Mardi'},
          {'value': 3, 'label': 'Mercredi'},
          {'value': 4, 'label': 'Jeudi'},
          {'value': 5, 'label': 'Vendredi'},
          {'value': 6, 'label': 'Samedi'},
          {'value': 7, 'label': 'Dimanche'},
        ]);
      }

      final activeReminders = await configRepo.getActiveReminderOptions();
      if (activeReminders.isNotEmpty) {
        reminderOptions.assignAll(activeReminders);
      } else {
        reminderOptions.assignAll(const [
          {'value': null, 'label': 'Aucun rappel'},
          {'value': 5, 'label': '5 minutes avant'},
          {'value': 10, 'label': '10 minutes avant'},
          {'value': 15, 'label': '15 minutes avant'},
          {'value': 30, 'label': '30 minutes avant'},
          {'value': 60, 'label': '1 heure avant'},
        ]);
      }
    } catch (_) {
      days.assignAll(const [
        {'value': 1, 'label': 'Lundi'},
        {'value': 2, 'label': 'Mardi'},
        {'value': 3, 'label': 'Mercredi'},
        {'value': 4, 'label': 'Jeudi'},
        {'value': 5, 'label': 'Vendredi'},
        {'value': 6, 'label': 'Samedi'},
        {'value': 7, 'label': 'Dimanche'},
      ]);
      reminderOptions.assignAll(const [
        {'value': null, 'label': 'Aucun rappel'},
        {'value': 5, 'label': '5 minutes avant'},
        {'value': 10, 'label': '10 minutes avant'},
        {'value': 15, 'label': '15 minutes avant'},
        {'value': 30, 'label': '30 minutes avant'},
        {'value': 60, 'label': '1 heure avant'},
      ]);
    }
  }

  Future<void> saveActivity() async {
    if (!form.valid) {
      form.markAllAsTouched();
      if (form.hasError('timeOrder')) {
        Get.snackbar(
          'Horaire invalide',
          "L'heure de fin doit être postérieure à l'heure de début.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      return;
    }

    final value = form.value;
    final title = (value['title'] as String?)?.trim() ?? '';
    final description = (value['description'] as String?)?.trim();
    final location = (value['location'] as String?)?.trim();
    final dayOfWeek = (value['dayOfWeek'] as int?) ?? 1;
    final startTime = (value['startTime'] as TimeOfDay?) ?? const TimeOfDay(hour: 8, minute: 0);
    final endTime = (value['endTime'] as TimeOfDay?) ?? const TimeOfDay(hour: 9, minute: 30);
    final category = (value['category'] as ActivityCategory?) ?? ActivityCategory.cours;
    final isRecurring = (value['isRecurring'] as bool?) ?? true;
    final reminderMinutes = value['reminderMinutesBefore'] as int?;

    isSaving.value = true;
    try {
      if (isEditing.value && existingActivity != null) {
        final updated = existingActivity!.copyWith(
          title: title,
          description: description?.isEmpty ?? true ? null : description,
          location: location?.isEmpty ?? true ? null : location,
          dayOfWeek: dayOfWeek,
          startHour: startTime.hour,
          startMinute: startTime.minute,
          endHour: endTime.hour,
          endMinute: endTime.minute,
          category: category,
          isRecurring: isRecurring,
          reminderMinutesBefore: reminderMinutes,
        );

        await activityRepo.updateActivity(updated);
        await notificationService.scheduleActivityNotification(updated);

        Get.back(result: true);
        Get.snackbar(
          'Activité modifiée',
          '"${updated.title}" a été mise à jour avec succès.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final newActivity = Activity(
          id: const Uuid().v4(),
          title: title,
          description: description?.isEmpty ?? true ? null : description,
          location: location?.isEmpty ?? true ? null : location,
          dayOfWeek: dayOfWeek,
          startHour: startTime.hour,
          startMinute: startTime.minute,
          endHour: endTime.hour,
          endMinute: endTime.minute,
          category: category,
          isRecurring: isRecurring,
          reminderMinutesBefore: reminderMinutes,
        );

        await activityRepo.addActivity(newActivity);
        await notificationService.scheduleActivityNotification(newActivity);

        Get.back(result: true);
        Get.snackbar(
          'Activité créée',
          '"${newActivity.title}" a été ajoutée avec succès.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}
