import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/unplanned_task.dart';
import '../../../widgets/form/app_text_input_field.dart';

/// Contrôleur GetX dédié au BottomSheet d'ajout rapide d'une tâche imprévue avec reactive_forms
class QuickTaskController extends BaseController {
  late final FormGroup form;

  final selectedDate = DateTime.now().obs;
  final targetTime = Rxn<TimeOfDay>();
  final showNotes = false.obs;
  final isLoading = false.obs;

  void init(DateTime? initialDate) {
    selectedDate.value = initialDate ?? DateTime.now();
    form = FormGroup({
      'title': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'description': FormControl<String>(value: ''),
      'priority': FormControl<TaskPriority>(
        value: TaskPriority.normal,
        validators: [Validators.required],
      ),
      'category': FormControl<ActivityCategory>(
        value: ActivityCategory.autre,
        validators: [Validators.required],
      ),
      'duration': FormControl<int?>(),
    });
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }

  void setDate(DateTime date) => selectedDate.value = date;
  void toggleShowNotes() => showNotes.value = !showNotes.value;

  Future<void> submit() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    final value = form.value;
    final title = (value['title'] as String?)?.trim() ?? '';
    final description = (value['description'] as String?)?.trim();
    final priority = (value['priority'] as TaskPriority?) ?? TaskPriority.normal;
    final category = (value['category'] as ActivityCategory?) ?? ActivityCategory.autre;
    final duration = value['duration'] as int?;

    isLoading.value = true;
    try {
      final task = UnplannedTask(
        id: const Uuid().v4(),
        title: title,
        description: description?.isEmpty ?? true ? null : description,
        date: selectedDate.value,
        priority: priority,
        category: category,
        targetTime: targetTime.value != null
            ? '${targetTime.value!.hour.toString().padLeft(2, '0')}:${targetTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        estimatedMinutes: duration,
      );

      await unplannedRepo.addTask(task);

      Get.back(result: task);
      Get.snackbar(
        'Tâche ajoutée',
        'Tâche imprévue "$title" enregistrée ! ⚡',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

/// Modal BottomSheet GetX pour la création ultra-rapide d'une tâche imprévue avec reactive_forms
class QuickTaskSheet extends StatelessWidget {
  final DateTime? initialDate;

  const QuickTaskSheet({super.key, this.initialDate});

  static Future<UnplannedTask?> show(
    BuildContext context, {
    DateTime? initialDate,
  }) {
    final controller = Get.put(QuickTaskController());
    controller.init(initialDate);

    return Get.bottomSheet<UnplannedTask>(
      QuickTaskSheet(initialDate: initialDate),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      Get.delete<QuickTaskController>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuickTaskController>();
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poignée de glissement supérieure
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
                  const SizedBox(height: 12),

                  // En-tête avec titre & badge "Éclair / Imprévu"
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nouvelle tâche imprévue',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Ajoutez une urgence ou un to-do sans planifier d\'horaire lourd',
                              style: TextStyle(
                                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Champ de saisie Titre
                  const AppTextInputField(
                    formControlName: 'title',
                    label: 'Titre de l\'imprévu',
                    hint: 'Ex: Répondre au client urgent, débloquer le serveur...',
                    prefixIcon: Icons.check_circle_outline_rounded,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),

                  // 2. Sélecteur rapide de Date
                  Obx(() {
                    final selDate = controller.selectedDate.value;
                    final now = DateTime.now();
                    final isToday = selDate.year == now.year &&
                        selDate.month == now.month &&
                        selDate.day == now.day;
                    final isTomorrow = selDate.year == now.year &&
                        selDate.month == now.month &&
                        selDate.day == now.day + 1;

                    return Row(
                      children: [
                        Text(
                          'Échéance :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          theme: theme,
                          isDark: isDark,
                          label: 'Aujourd\'hui',
                          isSelected: isToday,
                          onTap: () => controller.setDate(DateTime.now()),
                          icon: Icons.today_rounded,
                        ),
                        const SizedBox(width: 6),
                        _buildChip(
                          theme: theme,
                          isDark: isDark,
                          label: 'Demain',
                          isSelected: isTomorrow,
                          onTap: () =>
                              controller.setDate(DateTime.now().add(const Duration(days: 1))),
                          icon: Icons.event_rounded,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),

                  // 3. Sélecteur de Priorité
                  ReactiveValueListenableBuilder<TaskPriority>(
                    formControlName: 'priority',
                    builder: (context, control, child) {
                      final currentPriority = control.value ?? TaskPriority.normal;
                      return Row(
                        children: [
                          Text(
                            'Priorité :',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: TaskPriority.values.map((p) {
                                  final isSel = currentPriority == p;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _buildPriorityBadge(p, isSel, () {
                                      control.value = p;
                                    }),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Catégorie & Durée estimée
                  Row(
                    children: [
                      // Catégorie
                      Expanded(
                        child: ReactiveValueListenableBuilder<ActivityCategory>(
                          formControlName: 'category',
                          builder: (context, control, child) {
                            final currentCat = control.value ?? ActivityCategory.autre;
                            return InkWell(
                              onTap: () => _showCategoryPicker(context, control),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(currentCat.icon, size: 16, color: currentCat.color),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        currentCat.label,
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down_rounded, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Durée
                      Expanded(
                        child: ReactiveValueListenableBuilder<int?>(
                          formControlName: 'duration',
                          builder: (context, control, child) {
                            final currentDur = control.value;
                            return InkWell(
                              onTap: () => _showDurationPicker(context, control),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        currentDur != null
                                            ? '${currentDur}m'
                                            : 'Durée libre',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down_rounded, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. Notes / Description dépliables
                  Obx(
                    () => AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: controller.showNotes.value
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: controller.toggleShowNotes,
                          icon: const Icon(Icons.notes_rounded, size: 16),
                          label: const Text('Ajouter une note descriptive',
                              style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      secondChild: const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 8),
                        child: AppTextInputField(
                          formControlName: 'description',
                          label: 'Notes / Détails complémentaires',
                          hint: 'Instructions, contexte ou liens utiles...',
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Bouton Soumettre
                  Obx(
                    () => FilledButton.icon(
                      onPressed: controller.isLoading.value ? null : controller.submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.flash_on_rounded),
                      label: Text(
                        controller.isLoading.value ? 'Enregistrement...' : 'Créer l\'imprévu',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildChip({
    required ThemeData theme,
    required bool isDark,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority p, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? p.color : p.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? p.color : p.color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          p.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : p.color,
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, AbstractControl<ActivityCategory> control) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ActivityCategory.values.map((cat) {
            return ListTile(
              leading: Icon(cat.icon, color: cat.color),
              title: Text(cat.label),
              onTap: () {
                control.value = cat;
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context, AbstractControl<int?> control) {
    const durations = [
      {'label': 'Durée libre (non définie)', 'val': null},
      {'label': '15 minutes', 'val': 15},
      {'label': '30 minutes', 'val': 30},
      {'label': '45 minutes', 'val': 45},
      {'label': '1 heure (60m)', 'val': 60},
      {'label': '1h30 (90m)', 'val': 90},
      {'label': '2 heures (120m)', 'val': 120},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((d) {
            return ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(d['label'] as String),
              onTap: () {
                control.value = d['val'] as int?;
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
