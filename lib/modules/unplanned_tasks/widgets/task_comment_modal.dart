import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/unplanned_task.dart';

/// Contrôleur GetX dédié au BottomSheet de suivi et commentaires d'une tâche
class TaskCommentController extends BaseController {

  final commentController = TextEditingController();
  final commentFocus = FocusNode();

  final task = Rxn<UnplannedTask>();
  final isSubmitting = false.obs;

  void init(String taskId) {
    task.value = unplannedRepo.getTaskById(taskId);
  }

  @override
  void onClose() {
    commentController.dispose();
    commentFocus.dispose();
    super.onClose();
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || task.value == null) return;

    isSubmitting.value = true;
    commentController.clear();
    commentFocus.unfocus();

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

    Get.back(result: updated);
    Get.snackbar(
      'Tâche reportée',
      'Tâche reportée à demain ($newDateStr) ➡️',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> toggleCompletion() async {
    if (task.value == null) return;
    await unplannedRepo.toggleTaskCompletion(task.value!.id);
    task.value = unplannedRepo.getTaskById(task.value!.id);
  }
}

/// Modal BottomSheet GetX affichant les détails d'une tâche, son fil de commentaires et options de report
class TaskCommentModal extends StatelessWidget {
  final String taskId;

  const TaskCommentModal({super.key, required this.taskId});

  static Future<void> show(BuildContext context, {required String taskId}) {
    final controller = Get.put(TaskCommentController());
    controller.init(taskId);

    return Get.bottomSheet(
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final task = controller.task.value;

            if (task == null) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: const Center(child: Text('Tâche introuvable ou supprimée.')),
              );
            }

            final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(task.date);
            final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Poignée supérieure
                const SizedBox(height: 10),
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

                // 2. En-tête avec titre & badges
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Badge Priorité
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: task.priority.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(task.priority.icon, size: 12, color: task.priority.color),
                                const SizedBox(width: 4),
                                Text(
                                  task.priority.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: task.priority.color,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Badge Catégorie
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: task.category.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: task.category.color,
                              ),
                            ),
                          ),

                          // Badge Reporté
                          if (task.postponedCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.forward_rounded, size: 12, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Reporté (${task.postponedCount}x)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📅 Prévue pour : $capitalizedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (task.description != null && task.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(task.description!, style: const TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 3. Boutons d'actions rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.postponeToTomorrow,
                          icon: const Icon(Icons.forward_rounded, size: 16, color: Colors.orange),
                          label: const Text('Reporter à demain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.toggleCompletion,
                          icon: Icon(
                            task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                            size: 16,
                          ),
                          label: Text(
                            task.isCompleted ? 'À faire' : 'Terminer',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: task.isCompleted
                                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                                : theme.colorScheme.primary,
                            foregroundColor: task.isCompleted ? theme.colorScheme.onSurface : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 4. Liste des commentaires
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Commentaires & Suivi (${task.comments.length})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: task.comments.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun commentaire pour le moment.\nAjoutez une note ou une explication ci-dessous.',
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
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(comment, style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                ),

                // 5. Zone de saisie du nouveau commentaire
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: controller.commentController,
                            focusNode: controller.commentFocus,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => controller.submitComment(),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Ajouter un commentaire / note...',
                              hintStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: controller.isSubmitting.value ? null : controller.submitComment,
                        icon: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
