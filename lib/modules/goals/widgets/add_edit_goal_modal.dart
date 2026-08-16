import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/goal.dart';
import '../../../widgets/form/app_text_input_field.dart';
import '../../../widgets/form/app_time_picker_field.dart';

/// Contrôleur GetX dédié au modal d'ajout et d'édition d'un objectif avec reactive_forms
class AddEditGoalController extends BaseController {
  late final FormGroup form;

  final deadlineDate = DateTime.now().obs;
  final isSaving = false.obs;
  final isEditing = false.obs;
  Goal? existingGoal;

  void initGoal(Goal? goal) {
    existingGoal = goal;
    isEditing.value = goal != null;

    double initialVal = goal?.targetValue ?? 60.0;
    if (goal?.type == GoalType.fullTime) {
      initialVal = (goal?.targetValue ?? 420.0) / 60.0;
    }
    final targetStr = initialVal % 1 == 0 ? initialVal.toInt().toString() : initialVal.toString();

    TimeOfDay? initialDeadlineTime;
    if (goal?.deadline != null) {
      deadlineDate.value = goal!.deadline!;
      initialDeadlineTime = TimeOfDay(hour: goal.deadline!.hour, minute: goal.deadline!.minute);
    }

    form = FormGroup({
      'title': FormControl<String>(
        value: goal?.title ?? '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'description': FormControl<String>(
        value: goal?.description ?? '',
      ),
      'type': FormControl<GoalType>(
        value: goal?.type ?? GoalType.fullTime,
        validators: [Validators.required],
      ),
      'period': FormControl<GoalPeriod>(
        value: goal?.period ?? GoalPeriod.daily,
        validators: [Validators.required],
      ),
      'targetValue': FormControl<String>(
        value: targetStr,
        validators: [Validators.required, Validators.number()],
      ),
      'deadlineTime': FormControl<TimeOfDay>(
        value: initialDeadlineTime,
      ),
      'category': FormControl<ActivityCategory?>(
        value: goal?.category,
      ),
    });
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }

  void applyPreset(
    String title,
    GoalType type,
    double targetValHours,
    ActivityCategory? cat,
    TimeOfDay? deadline,
  ) {
    form.control('title').value = title;
    form.control('type').value = type;
    form.control('category').value = cat;
    form.control('deadlineTime').value = deadline;
    form.control('targetValue').value = targetValHours % 1 == 0
        ? targetValHours.toInt().toString()
        : targetValHours.toString();
  }

  Future<void> saveGoal() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    final value = form.value;
    final title = (value['title'] as String?)?.trim() ?? '';
    final description = (value['description'] as String?)?.trim();
    final type = (value['type'] as GoalType?) ?? GoalType.fullTime;
    final period = (value['period'] as GoalPeriod?) ?? GoalPeriod.daily;
    final targetStr = value['targetValue'] as String? ?? '1';
    final parsedVal = double.tryParse(targetStr.trim()) ?? 1.0;
    final finalTargetVal = type == GoalType.fullTime ? (parsedVal * 60.0) : parsedVal;
    final deadlineTime = value['deadlineTime'] as TimeOfDay?;
    final category = value['category'] as ActivityCategory?;

    DateTime? finalDeadline;
    if (type == GoalType.timeLimited && deadlineTime != null) {
      finalDeadline = DateTime(
        deadlineDate.value.year,
        deadlineDate.value.month,
        deadlineDate.value.day,
        deadlineTime.hour,
        deadlineTime.minute,
      );
    }

    isSaving.value = true;
    try {
      final goal = Goal(
        id: existingGoal?.id ?? const Uuid().v4(),
        title: title,
        description: description?.isEmpty ?? true ? null : description,
        type: type,
        period: period,
        targetValue: finalTargetVal,
        currentValue: existingGoal?.currentValue ?? 0.0,
        deadline: finalDeadline,
        category: category,
        isCompleted: existingGoal?.isCompleted ?? false,
      );

      if (isEditing.value) {
        await goalRepo.updateGoal(goal);
      } else {
        await goalRepo.addGoal(goal);
      }

      Get.back(result: goal);
      Get.snackbar(
        isEditing.value ? 'Objectif modifié' : 'Objectif créé',
        'Objectif "${goal.title}" enregistré ! 🎯',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erreur', '$e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent);
    } finally {
      isSaving.value = false;
    }
  }
}

/// Modal GetX pour la création ou l'édition d'un objectif avec reactive_forms
class AddEditGoalModal extends StatelessWidget {
  final Goal? goal;

  const AddEditGoalModal({super.key, this.goal});

  static Future<Goal?> show(BuildContext context, {Goal? goal}) {
    final controller = Get.put(AddEditGoalController());
    controller.initGoal(goal);

    return Get.bottomSheet<Goal>(
      AddEditGoalModal(goal: goal),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      Get.delete<AddEditGoalController>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddEditGoalController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ReactiveForm(
      formGroup: controller.form,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.track_changes_rounded,
                            color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => Text(
                            controller.isEditing.value
                                ? 'Modifier l\'objectif'
                                : 'Nouvel Objectif & Défi',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Presets rapides
                  if (!controller.isEditing.value) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip(
                            '⏳ Temps plein 8h',
                            () => controller.applyPreset(
                              '8h de travail effectif',
                              GoalType.fullTime,
                              8.0,
                              ActivityCategory.travail,
                              null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildPresetChip(
                            '⏱️ Fin avant 18h',
                            () => controller.applyPreset(
                              'Boucler urgences avant 18h',
                              GoalType.timeLimited,
                              1.0,
                              null,
                              const TimeOfDay(hour: 18, minute: 0),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildPresetChip(
                            '📋 5 tâches',
                            () => controller.applyPreset(
                              'Réaliser 5 tâches du jour',
                              GoalType.taskCount,
                              5.0,
                              null,
                              null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Champ Titre
                  const AppTextInputField(
                    formControlName: 'title',
                    label: 'Titre de l\'objectif',
                    hint: 'Ex: 7h de travail, Finir dossier client avant 17h...',
                    prefixIcon: Icons.flag_rounded,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),

                  // Type d'objectif
                  ReactiveValueListenableBuilder<GoalType>(
                    formControlName: 'type',
                    builder: (context, control, child) {
                      final currentType = control.value ?? GoalType.fullTime;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<GoalType>(
                            segments: const [
                              ButtonSegment(
                                value: GoalType.fullTime,
                                label: Text('⏳ Temps Plein'),
                                icon: Icon(Icons.timer_rounded),
                              ),
                              ButtonSegment(
                                value: GoalType.timeLimited,
                                label: Text('⏱️ Temps Limité'),
                                icon: Icon(Icons.alarm_rounded),
                              ),
                              ButtonSegment(
                                value: GoalType.taskCount,
                                label: Text('📋 Tâches'),
                                icon: Icon(Icons.checklist_rounded),
                              ),
                            ],
                            selected: {currentType},
                            onSelectionChanged: (set) {
                              control.value = set.first;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Champ dynamique selon le type
                          if (currentType == GoalType.fullTime) ...[
                            const AppTextInputField(
                              formControlName: 'targetValue',
                              label: 'Durée cible cumulée (en heures)',
                              hint: 'Ex: 7 (pour 7 heures), 35 (semaine)...',
                              prefixIcon: Icons.hourglass_bottom_rounded,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              isRequired: true,
                            ),
                          ] else if (currentType == GoalType.taskCount) ...[
                            const AppTextInputField(
                              formControlName: 'targetValue',
                              label: 'Nombre d\'activités à compléter',
                              hint: 'Ex: 5',
                              prefixIcon: Icons.format_list_numbered_rounded,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                            ),
                          ] else ...[
                            const AppTimePickerField(
                              formControlName: 'deadlineTime',
                              label: 'Heure butoir de complétion',
                              prefixIcon: Icons.alarm_on_rounded,
                              isRequired: true,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bouton Enregistrer
                  Obx(
                    () => FilledButton.icon(
                      onPressed: controller.isSaving.value ? null : controller.saveGoal,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        controller.isSaving.value
                            ? 'Enregistrement...'
                            : (controller.isEditing.value ? 'Mettre à jour' : 'Créer l\'objectif'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      onPressed: onTap,
    );
  }
}
