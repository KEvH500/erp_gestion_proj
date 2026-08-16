import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/activity.dart';

/// Contrôleur GetX pour le formulaire d'ajout et d'édition d'activité
class ActivityFormController extends BaseController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;

  final selectedDayOfWeek = 1.obs;
  final startTime = const TimeOfDay(hour: 8, minute: 0).obs;
  final endTime = const TimeOfDay(hour: 9, minute: 30).obs;
  final selectedCategory = ActivityCategory.cours.obs;
  final isRecurring = true.obs;
  final selectedReminderMinutes = Rxn<int>();
  final isEditing = false.obs;
  final isSaving = false.obs;

  Activity? existingActivity;

  // Jours et options de rappel réactifs chargés dynamiquement depuis SQLite
  final days = <Map<String, dynamic>>[].obs;
  final reminderOptions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    loadConfigFromSqlite();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> loadConfigFromSqlite() async {
    try {
      final activeDays = await configRepo.getActiveDays();
      if (activeDays.isNotEmpty) {
        days.assignAll(activeDays);
      } else {
        // Repli par défaut si jamais la base était vierge
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
      // Sécurité en cas d'accès SQLite initial
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

  void _initData() {
    if (Get.arguments is Activity) {
      existingActivity = Get.arguments as Activity;
      isEditing.value = true;
    }

    final a = existingActivity;
    titleController = TextEditingController(text: a?.title ?? '');
    descriptionController = TextEditingController(text: a?.description ?? '');
    locationController = TextEditingController(text: a?.location ?? '');

    if (a != null) {
      selectedDayOfWeek.value = a.dayOfWeek;
      startTime.value = TimeOfDay(hour: a.startHour, minute: a.startMinute);
      endTime.value = TimeOfDay(hour: a.endHour, minute: a.endMinute);
      selectedCategory.value = a.category;
      isRecurring.value = a.isRecurring;
      selectedReminderMinutes.value = a.reminderMinutesBefore;
    } else {
      if (Get.parameters.containsKey('day')) {
        final dayParam = int.tryParse(Get.parameters['day'] ?? '1');
        if (dayParam != null && dayParam >= 1 && dayParam <= 7) {
          selectedDayOfWeek.value = dayParam;
        }
      } else {
        selectedDayOfWeek.value = DateTime.now().weekday;
      }
    }
  }

  void setStartTime(TimeOfDay picked) {
    startTime.value = picked;
    final startTotal = startTime.value.hour * 60 + startTime.value.minute;
    final endTotal = endTime.value.hour * 60 + endTime.value.minute;

    if (endTotal <= startTotal) {
      endTime.value = TimeOfDay(
        hour: (startTime.value.hour + 1) % 24,
        minute: startTime.value.minute,
      );
    }
  }

  void setEndTime(TimeOfDay picked) {
    endTime.value = picked;
  }

  String formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> saveActivity() async {
    if (!formKey.currentState!.validate()) return;

    final startTotal = startTime.value.hour * 60 + startTime.value.minute;
    final endTotal = endTime.value.hour * 60 + endTime.value.minute;

    if (endTotal <= startTotal) {
      Get.snackbar(
        'Horaire invalide',
        "L'heure de fin doit être postérieure à l'heure de début.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSaving.value = true;
    try {
      if (isEditing.value && existingActivity != null) {
        final updated = existingActivity!.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          location: locationController.text.trim().isEmpty
              ? null
              : locationController.text.trim(),
          dayOfWeek: selectedDayOfWeek.value,
          startHour: startTime.value.hour,
          startMinute: startTime.value.minute,
          endHour: endTime.value.hour,
          endMinute: endTime.value.minute,
          category: selectedCategory.value,
          isRecurring: isRecurring.value,
          reminderMinutesBefore: selectedReminderMinutes.value,
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
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          location: locationController.text.trim().isEmpty
              ? null
              : locationController.text.trim(),
          dayOfWeek: selectedDayOfWeek.value,
          startHour: startTime.value.hour,
          startMinute: startTime.value.minute,
          endHour: endTime.value.hour,
          endMinute: endTime.value.minute,
          category: selectedCategory.value,
          isRecurring: isRecurring.value,
          reminderMinutesBefore: selectedReminderMinutes.value,
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
