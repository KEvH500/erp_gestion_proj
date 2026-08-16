import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/goal.dart';

/// Contrôleur GetX dédié au modal d'ajout et d'édition d'un objectif
class AddEditGoalController extends BaseController {

  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController targetValueController;

  final selectedType = GoalType.fullTime.obs;
  final selectedPeriod = GoalPeriod.daily.obs;
  final selectedCategory = Rxn<ActivityCategory>();
  final deadlineTime = Rxn<TimeOfDay>();
  final deadlineDate = DateTime.now().obs;

  final isSaving = false.obs;
  final isEditing = false.obs;
  Goal? existingGoal;

  void initGoal(Goal? goal) {
    existingGoal = goal;
    isEditing.value = goal != null;

    titleController = TextEditingController(text: goal?.title ?? '');
    descriptionController = TextEditingController(text: goal?.description ?? '');

    double initialVal = goal?.targetValue ?? 60.0;
    if (goal?.type == GoalType.fullTime) {
      initialVal = (goal?.targetValue ?? 420.0) / 60.0;
    }
    targetValueController = TextEditingController(
      text: initialVal % 1 == 0 ? initialVal.toInt().toString() : initialVal.toString(),
    );

    selectedType.value = goal?.type ?? GoalType.fullTime;
    selectedPeriod.value = goal?.period ?? GoalPeriod.daily;
    selectedCategory.value = goal?.category;

    if (goal?.deadline != null) {
      deadlineDate.value = goal!.deadline!;
      deadlineTime.value = TimeOfDay(hour: goal.deadline!.hour, minute: goal.deadline!.minute);
    } else {
      deadlineTime.value = null;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    targetValueController.dispose();
    super.onClose();
  }

  void applyPreset(String title, GoalType type, double targetValHours, ActivityCategory? cat, TimeOfDay? deadline) {
    titleController.text = title;
    selectedType.value = type;
    selectedCategory.value = cat;
    deadlineTime.value = deadline;
    targetValueController.text = targetValHours % 1 == 0 ? targetValHours.toInt().toString() : targetValHours.toString();
  }

  void setType(GoalType type) {
    selectedType.value = type;
    if (type == GoalType.fullTime && targetValueController.text.isEmpty) {
      targetValueController.text = '7';
    }
  }

  void setDeadlineTime(TimeOfDay? time) {
    deadlineTime.value = time;
  }

  Future<void> saveGoal() async {
    if (!formKey.currentState!.validate()) return;

    final parsedVal = double.tryParse(targetValueController.text.trim()) ?? 1.0;
    final finalTargetVal = selectedType.value == GoalType.fullTime ? (parsedVal * 60.0) : parsedVal;

    DateTime? finalDeadline;
    if (selectedType.value == GoalType.timeLimited && deadlineTime.value != null) {
      finalDeadline = DateTime(
        deadlineDate.value.year,
        deadlineDate.value.month,
        deadlineDate.value.day,
        deadlineTime.value!.hour,
        deadlineTime.value!.minute,
      );
    }

    isSaving.value = true;
    try {
      final goal = Goal(
        id: existingGoal?.id ?? const Uuid().v4(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        type: selectedType.value,
        period: selectedPeriod.value,
        targetValue: finalTargetVal,
        currentValue: existingGoal?.currentValue ?? 0.0,
        deadline: finalDeadline,
        category: selectedCategory.value,
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
      Get.snackbar('Erreur', '$e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent);
    } finally {
      isSaving.value = false;
    }
  }
}

/// Modal GetX pour la création ou l'édition d'un objectif
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

    return Padding(
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
            child: Form(
              key: controller.formKey,
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
                        child: Icon(Icons.track_changes_rounded, color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.isEditing.value ? 'Modifier l\'objectif' : 'Nouvel Objectif & Défi',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Presets rapides
                  if (!controller.isEditing.value) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip('⏳ Temps plein 8h', () => controller.applyPreset('8h de travail effectif', GoalType.fullTime, 8.0, ActivityCategory.travail, null)),
                          const SizedBox(width: 6),
                          _buildPresetChip('⏱️ Fin avant 18h', () => controller.applyPreset('Boucler urgences avant 18h', GoalType.timeLimited, 1.0, null, const TimeOfDay(hour: 18, minute: 0))),
                          const SizedBox(width: 6),
                          _buildPresetChip('📋 5 tâches', () => controller.applyPreset('Réaliser 5 tâches du jour', GoalType.taskCount, 5.0, null, null)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Champ Titre
                  TextFormField(
                    controller: controller.titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre de l\'objectif *',
                      hintText: 'Ex: 7h de travail, Finir dossier client avant 17h...',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Titre requis.' : null,
                  ),
                  const SizedBox(height: 14),

                  // Type d'objectif
                  Obx(
                    () => SegmentedButton<GoalType>(
                      segments: const [
                        ButtonSegment(value: GoalType.fullTime, label: Text('⏳ Temps Plein'), icon: Icon(Icons.timer_rounded)),
                        ButtonSegment(value: GoalType.timeLimited, label: Text('⏱️ Temps Limité'), icon: Icon(Icons.alarm_rounded)),
                        ButtonSegment(value: GoalType.taskCount, label: Text('📋 Tâches'), icon: Icon(Icons.checklist_rounded)),
                      ],
                      selected: {controller.selectedType.value},
                      onSelectionChanged: (set) => controller.setType(set.first),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Valeur cible
                  Obx(() {
                    final type = controller.selectedType.value;
                    if (type == GoalType.fullTime) {
                      return TextFormField(
                        controller: controller.targetValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Durée cible cumulée (en heures) *',
                          hintText: 'Ex: 7 (pour 7 heures), 35 (semaine)...',
                          prefixIcon: Icon(Icons.hourglass_bottom_rounded),
                          suffixText: 'heures',
                        ),
                        validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0 ? 'Entrez un nombre > 0' : null,
                      );
                    } else if (type == GoalType.taskCount) {
                      return TextFormField(
                        controller: controller.targetValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre d\'activités ou tâches à compléter *',
                          hintText: 'Ex: 5',
                          prefixIcon: Icon(Icons.format_list_numbered_rounded),
                          suffixText: 'tâches',
                        ),
                        validator: (val) => (int.tryParse(val ?? '') ?? 0) <= 0 ? 'Entrez un nombre entier > 0' : null,
                      );
                    } else {
                      final time = controller.deadlineTime.value;
                      return OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time ?? const TimeOfDay(hour: 18, minute: 0),
                          );
                          if (picked != null) {
                            controller.setDeadlineTime(picked);
                          }
                        },
                        icon: const Icon(Icons.alarm_on_rounded),
                        label: Text(
                          time == null
                              ? 'Définir l\'heure butoir *'
                              : 'Heure butoir : ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 24),

                  // Bouton Enregistrer
                  Obx(
                    () => FilledButton.icon(
                      onPressed: controller.isSaving.value ? null : controller.saveGoal,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: controller.isSaving.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
