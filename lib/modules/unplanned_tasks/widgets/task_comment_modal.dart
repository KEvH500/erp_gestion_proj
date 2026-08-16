import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/unplanned_task.dart';
import '../../../widgets/form/app_text_input_field.dart';

/// Contrôleur GetX dédié au BottomSheet de suivi et commentaires d'une tâche avec reactive_forms
class TaskCommentController extends BaseController {
  late final FormGroup form;

  final task = Rxn<UnplannedTask>();
  final isSubmitting = false.obs;

  void init(String taskId) {
    task.value = unplannedRepo.getTaskById(taskId);
    form = FormGroup({
      'comment': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
    });
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }

  Future<void> submitComment() async {
    if (!form.valid || task.value == null) {
      form.markAllAsTouched();
      return;
    }

    final text = (form.control('comment').value as String?)?.trim() ?? '';
    if (text.isEmpty) return;

    isSubmitting.value = true;
    form.control('comment').reset();

    final timestamp = DateFormat('dd/MM HH:mm', 'fr_FR').format(DateTime.now());
    final newComment = '[$timestamp] $text';
    final updatedComments = List<String>.from(task.value!.comments)..add(newComment);
    final updated = task.value!.copyWith(comments: updatedComments);

    await unplannedRepo.updateTask(updated);
    task.value = updated;
    isSubmitting.value = false;
  }

  Future<void> postponeToTomorrow() async {
    if (task.value == null) return;

    final nextDay = task.value!.date.add(const Duration(days: 1));
    final prevDateStr = DateFormat('dd/MM', 'fr_FR').format(task.value!.date);
    final newDateStr = DateFormat('dd/MM', 'fr_FR').format(nextDay);
    final timestamp = DateFormat('dd/MM HH:mm', 'fr_FR').format(DateTime.now());

    final updatedComments = List<String>.from(task.value!.comments)
      ..add('[$timestamp] ➡️ Reportée du $prevDateStr au $newDateStr');

    final updated = task.value!.copyWith(
      date: nextDay,
      originalDate: task.value!.originalDate ?? task.value!.date,
      postponedCount: task.value!.postponedCount + 1,
      comments: updatedComments,
    );

    await unplannedRepo.updateTask(updated);
    task.value = updated;

    Get.snackbar(
      'Tâche reportée',
      'Reportée à demain ($newDateStr). Total reports : ${updated.postponedCount}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> postponeByDays(int days) async {
    if (task.value == null) return;

    final newDate = task.value!.date.add(Duration(days: days));
    final prevDateStr = DateFormat('dd/MM', 'fr_FR').format(task.value!.date);
    final newDateStr = DateFormat('dd/MM', 'fr_FR').format(newDate);
    final timestamp = DateFormat('dd/MM HH:mm', 'fr_FR').format(DateTime.now());

    final updatedComments = List<String>.from(task.value!.comments)
      ..add('[$timestamp] ➡️ Reportée de $days jour(s) ($prevDateStr ➔ $newDateStr)');

    final updated = task.value!.copyWith(
      date: newDate,
      originalDate: task.value!.originalDate ?? task.value!.date,
      postponedCount: task.value!.postponedCount + 1,
      comments: updatedComments,
    );

    await unplannedRepo.updateTask(updated);
    task.value = updated;

    Get.snackbar(
      'Tâche reportée',
      'Reportée au $newDateStr (+ $days j).',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

/// BottomSheet GetX de suivi et ajout de commentaires sur une tâche imprévue avec reactive_forms
class TaskCommentModal extends StatelessWidget {
  final String taskId;

  const TaskCommentModal({super.key, required this.taskId});

  static Future<void> show(BuildContext context, {required String taskId}) {
    final controller = Get.put(TaskCommentController());
    controller.init(taskId);

    return Get.bottomSheet<void>(
      TaskCommentModal(taskId: taskId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      Get.delete<TaskCommentController>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskCommentController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final task = controller.task.value;
            if (task == null) {
              return const Center(child: Text('Tâche introuvable'));
            }

            final isOverdue = task.isOverdue;
            final isPostponed = task.isPostponed;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Barre de glissement
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 2. En-tête avec titre & badge de priorité
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: task.priority.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          task.priority.icon,
                          color: task.priority.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildTag(
                                  label: task.priority.label,
                                  color: task.priority.color,
                                ),
                                _buildTag(
                                  label: task.category.label,
                                  color: task.category.color,
                                ),
                                if (isPostponed)
                                  _buildTag(
                                    label: 'Reportée ${task.postponedCount}x',
                                    color: Colors.orange,
                                  ),
                                if (isOverdue)
                                  _buildTag(
                                    label: 'En retard',
                                    color: Colors.redAccent,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 3. Actions rapides de report
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Text(
                        'Reporter :',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionChip(
                                label: 'À demain',
                                icon: Icons.arrow_forward_rounded,
                                onTap: controller.postponeToTomorrow,
                              ),
                              const SizedBox(width: 6),
                              _buildActionChip(
                                label: '+2 jours',
                                icon: Icons.fast_forward_rounded,
                                onTap: () => controller.postponeByDays(2),
                              ),
                              const SizedBox(width: 6),
                              _buildActionChip(
                                label: 'Semaine pro (+7j)',
                                icon: Icons.next_week_rounded,
                                onTap: () => controller.postponeByDays(7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 4. Liste des commentaires et historique
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.forum_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Historique & Commentaires (${task.comments.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: task.comments.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun commentaire ou action enregistrée pour le moment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: task.comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final comment = task.comments[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(comment, style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                ),

                // 5. Zone de saisie du nouveau commentaire avec reactive_forms
                ReactiveForm(
                  formGroup: controller.form,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextInputField(
                            formControlName: 'comment',
                            label: 'Commentaire',
                            hint: 'Ajouter un commentaire ou une note...',
                            prefixIcon: Icons.edit_note_rounded,
                            onSubmitted: (_) => controller.submitComment(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitComment,
                          icon: const Icon(Icons.send_rounded, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTag({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      onPressed: onTap,
    );
  }
}
