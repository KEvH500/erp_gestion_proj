import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/unplanned_task.dart';

/// Contrôleur GetX dédié au BottomSheet d'ajout rapide d'une tâche imprévue
class QuickTaskController extends BaseController {

  late final TextEditingController titleController;
  late final TextEditingController descController;
  final focusNode = FocusNode();

  final selectedDate = DateTime.now().obs;
  final selectedPriority = TaskPriority.normal.obs;
  final selectedCategory = ActivityCategory.autre.obs;
  final selectedDuration = Rxn<int>();
  final targetTime = Rxn<TimeOfDay>();
  final showNotes = false.obs;
  final isLoading = false.obs;

  void init(DateTime? initialDate) {
    selectedDate.value = initialDate ?? DateTime.now();
    titleController = TextEditingController();
    descController = TextEditingController();
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void setDate(DateTime date) => selectedDate.value = date;
  void setPriority(TaskPriority priority) => selectedPriority.value = priority;
  void setCategory(ActivityCategory cat) => selectedCategory.value = cat;
  void setDuration(int? duration) => selectedDuration.value = duration;
  void toggleShowNotes() => showNotes.value = !showNotes.value;

  Future<void> submit() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Titre requis',
        'Veuillez entrer un titre pour la tâche.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final task = UnplannedTask(
        id: const Uuid().v4(),
        title: title,
        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
        date: selectedDate.value,
        priority: selectedPriority.value,
        category: selectedCategory.value,
        targetTime: targetTime.value != null
            ? '${targetTime.value!.hour.toString().padLeft(2, '0')}:${targetTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        estimatedMinutes: selectedDuration.value,
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

/// Modal BottomSheet GetX pour la création ultra-rapide d'une tâche imprévue
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

    return Padding(
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
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
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
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: TextField(
                    controller: controller.titleController,
                    focusNode: controller.focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.submit(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Ex: Répondre au client urgent, débloquer le serveur...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Sélecteur rapide de Date
                Obx(() {
                  final selDate = controller.selectedDate.value;
                  final now = DateTime.now();
                  final isToday = selDate.year == now.year && selDate.month == now.month && selDate.day == now.day;
                  final isTomorrow = selDate.year == now.year && selDate.month == now.month && selDate.day == now.day + 1;

                  return Row(
                    children: [
                      Text(
                        'Échéance :',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant),
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
                        onTap: () => controller.setDate(DateTime.now().add(const Duration(days: 1))),
                        icon: Icons.calendar_today_rounded,
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        theme: theme,
                        isDark: isDark,
                        label: (!isToday && !isTomorrow) ? DateFormat('d MMM', 'fr_FR').format(selDate) : 'Autre...',
                        isSelected: !isToday && !isTomorrow,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            controller.setDate(picked);
                          }
                        },
                        icon: Icons.edit_calendar_rounded,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 14),

                // 3. Sélecteur de Priorité
                Obx(
                  () => Row(
                    children: [
                      Text(
                        'Priorité :',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      for (final priority in TaskPriority.values) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildPriorityChip(controller, priority),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Catégorie
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Catégorie :',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        for (final cat in ActivityCategory.values) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _buildCategoryChip(controller, cat),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Options secondaires (Notes, Durée)
                Obx(() {
                  if (!controller.showNotes.value) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: controller.toggleShowNotes,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text(
                          'Ajouter détails / durée estimée',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      TextField(
                        controller: controller.descController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Notes complémentaires (optionnel)...',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Durée :',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 8),
                          for (final mins in [15, 30, 60]) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('$mins min'),
                                selected: controller.selectedDuration.value == mins,
                                onSelected: (selected) => controller.setDuration(selected ? mins : null),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                // 6. Bouton de soumission
                Obx(
                  () => SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Ajouter l\'imprévu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
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
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : theme.colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(QuickTaskController controller, TaskPriority priority) {
    final isSelected = controller.selectedPriority.value == priority;
    final color = priority.color;

    return InkWell(
      onTap: () => controller.setPriority(priority),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(priority.icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              priority.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(QuickTaskController controller, ActivityCategory cat) {
    final isSelected = controller.selectedCategory.value == cat;
    final color = cat.color;

    return InkWell(
      onTap: () => controller.setCategory(cat),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, size: 13, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              cat.label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }
}
