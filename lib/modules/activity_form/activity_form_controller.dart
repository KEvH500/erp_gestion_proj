import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/activity.dart';
import '../../models/recurrence_rule.dart';
import '../../services/overlap_checker.dart';
import '../../services/recurrence_engine.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import 'task_form_model.dart';

/// Contrôleur GetX pour le formulaire d'activité / tâche utilisant reactive_forms
class ActivityFormController extends BaseController {
  late final FormGroup form;

  final isEditing = false.obs;
  final isSaving = false.obs;
  Activity? existingActivity;

  // Jours et options de rappel réactifs chargés dynamiquement depuis SQLite
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
    DateTime? defaultStartDate;

    if (Get.parameters.containsKey('date')) {
      final dateParam = DateTime.tryParse(Get.parameters['date'] ?? '');
      if (dateParam != null) {
        defaultStartDate = dateParam;
      }
    } else if (Get.parameters.containsKey('day')) {
      final dayParam = int.tryParse(Get.parameters['day'] ?? '1');
      if (dayParam != null && dayParam >= 1 && dayParam <= 7) {
        defaultDay = dayParam;
      }
    }

    if (Get.arguments is Activity) {
      existingActivity = Get.arguments as Activity;
      isEditing.value = true;
    } else if (Get.arguments is DateTime) {
      defaultStartDate = Get.arguments as DateTime;
    }

    form = buildTaskForm(
      existingActivity: existingActivity,
      defaultStartDate: defaultStartDate,
      defaultDayOfWeek: defaultDay,
    );
  }

  Future<void> loadConfigFromSqlite() async {
    try {
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

  /// Bascule un jour de la semaine dans la sélection multi-jours
  void toggleWeekDay(int dayOfWeek) {
    final control = form.control('recurrenceWeekDays') as FormControl<List<int>>;
    final currentList = List<int>.from(control.value ?? []);
    if (currentList.contains(dayOfWeek)) {
      if (currentList.length > 1) {
        currentList.remove(dayOfWeek);
      }
    } else {
      currentList.add(dayOfWeek);
      currentList.sort();
    }
    control.value = currentList;
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
    final startDate = (value['startDate'] as DateTime?) ?? DateTime.now();
    final startTime = (value['startTime'] as TimeOfDay?) ?? const TimeOfDay(hour: 8, minute: 0);
    final endTime = (value['endTime'] as TimeOfDay?) ?? const TimeOfDay(hour: 9, minute: 30);
    final category = (value['category'] as ActivityCategory?) ?? ActivityCategory.cours;
    final reminderMinutes = value['reminderMinutesBefore'] as int?;
    final isLocked = (value['isLocked'] as bool?) ?? false;

    // Récurrence
    final isRecurring = (value['isRecurring'] as bool?) ?? false;
    RecurrenceRule? recurrenceRule;

    if (isRecurring) {
      final frequency = (value['recurrenceFrequency'] as RecurrenceFrequency?) ?? RecurrenceFrequency.weekly;
      final interval = (value['recurrenceInterval'] as int?) ?? 1;
      final weekDays = (value['recurrenceWeekDays'] as List<int>?) ?? [startDate.weekday];
      final endType = (value['recurrenceEndType'] as RecurrenceEndType?) ?? RecurrenceEndType.never;
      final untilDate = value['recurrenceUntilDate'] as DateTime?;
      final count = value['recurrenceCount'] as int?;

      recurrenceRule = RecurrenceRule(
        id: existingActivity?.recurrenceRule?.id ?? const Uuid().v4(),
        frequency: frequency,
        interval: interval > 0 ? interval : 1,
        byWeekDays: frequency == RecurrenceFrequency.weekly ? weekDays.join(',') : null,
        endType: endType,
        untilDate: endType == RecurrenceEndType.untilDate ? untilDate : null,
        occurrenceCount: endType == RecurrenceEndType.count ? count : null,
      );
    }

    // 1. Contrôle de non-chevauchement des créneaux horaires
    final allActivities = activityRepo.getAllActivities();
    final checkDates = <DateTime>[startDate];

    if (isRecurring && recurrenceRule != null) {
      final occurrences = RecurrenceEngine.generateOccurrences(
        activity: Activity(
          id: existingActivity?.id ?? 'temp-candidate',
          title: title,
          startDate: startDate,
          startHour: startTime.hour,
          startMinute: startTime.minute,
          endHour: endTime.hour,
          endMinute: endTime.minute,
          category: category,
          recurrenceRule: recurrenceRule,
          isLocked: isLocked,
        ),
        rangeStart: startDate,
        rangeEnd: startDate.add(const Duration(days: 35)),
      );
      for (final occ in occurrences) {
        checkDates.add(occ.startDate);
      }
    }

    final allBlockingConflicts = <Activity>[];
    for (final checkDate in checkDates.toSet()) {
      final checkResult = OverlapChecker.findOverlaps(
        targetDate: checkDate,
        startHour: startTime.hour,
        startMinute: startTime.minute,
        endHour: endTime.hour,
        endMinute: endTime.minute,
        isLocked: isLocked,
        allActivities: allActivities,
        excludeActivityId: existingActivity?.id,
      );
      if (checkResult.hasBlockingConflicts) {
        for (final conflict in checkResult.blockingConflicts) {
          if (!allBlockingConflicts.any((c) => c.id == conflict.id)) {
            allBlockingConflicts.add(conflict);
          }
        }
      }
    }

    if (allBlockingConflicts.isNotEmpty) {
      _showConflictWarningSheet(allBlockingConflicts);
      return;
    }

    isSaving.value = true;
    try {
      if (isEditing.value && existingActivity != null) {
        final updated = existingActivity!.copyWith(
          title: title,
          description: description?.isEmpty ?? true ? null : description,
          location: location?.isEmpty ?? true ? null : location,
          startDate: startDate,
          startHour: startTime.hour,
          startMinute: startTime.minute,
          endHour: endTime.hour,
          endMinute: endTime.minute,
          category: category,
          recurrenceRule: recurrenceRule,
          clearRecurrence: !isRecurring,
          reminderMinutesBefore: reminderMinutes,
          isLocked: isLocked,
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
          startDate: startDate,
          startHour: startTime.hour,
          startMinute: startTime.minute,
          endHour: endTime.hour,
          endMinute: endTime.minute,
          category: category,
          recurrenceRule: recurrenceRule,
          reminderMinutesBefore: reminderMinutes,
          isLocked: isLocked,
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

  /// Affiche le panneau modal d'avertissement de conflit bloquant
  void _showConflictWarningSheet(List<Activity> conflicts) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.rubis.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.rubis, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AppText.heading(
                    'Conflit d\'horaires détecté',
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AppText.body(
              'Cette tâche chevauche une ou plusieurs activités existantes sur le même créneau :',
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                children: conflicts.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border(
                        left: BorderSide(color: c.category.color, width: 3.5),
                        top: const BorderSide(color: AppColors.border, width: 0.5),
                        right: const BorderSide(color: AppColors.border, width: 0.5),
                        bottom: const BorderSide(color: AppColors.border, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText.body(
                            c.title,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        AppText.time(
                          c.timeRangeFormatted,
                          color: c.category.color,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            const AppText.caption(
              'Modifiez l\'horaire ou activez le verrouillage pour autoriser le chevauchement.',
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const AppText.label('Modifier l\'horaire', color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Get.back();
                      // Activer le verrouillage pour déroger sciemment
                      form.control('isLocked').value = true;
                      saveActivity();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const AppText.label(
                      'Verrouiller & Créer',
                      color: AppColors.background,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
