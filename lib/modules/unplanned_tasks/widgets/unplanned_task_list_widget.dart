import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../app/controllers/base_controller.dart';
import '../../../models/activity.dart';
import '../../../models/unplanned_task.dart';
import 'quick_task_sheet.dart';
import 'task_comment_modal.dart';

/// Contrôleur GetX pour la liste et les interactions des tâches imprévues
class UnplannedTaskListController extends BaseController {

  final currentDate = DateTime.now().obs;
  final isExpanded = true.obs;
  final tasks = <UnplannedTask>[].obs;
  final overdueTasks = <UnplannedTask>[].obs;

  late final TextEditingController inlineController;
  final inlineFocus = FocusNode();

  VoidCallback? onTasksChangedCallback;

  void init({required DateTime date, bool initiallyExpanded = true, VoidCallback? onTasksChanged}) {
    currentDate.value = date;
    isExpanded.value = initiallyExpanded;
    onTasksChangedCallback = onTasksChanged;
    inlineController = TextEditingController();
    loadTasks();
  }

  void updateDate(DateTime date) {
    if (currentDate.value != date) {
      currentDate.value = date;
      loadTasks();
    }
  }

  @override
  void onClose() {
    inlineController.dispose();
    inlineFocus.dispose();
    super.onClose();
  }

  void toggleExpanded() => isExpanded.value = !isExpanded.value;

  void loadTasks() {
    final dayTasks = unplannedRepo.getTasksForDate(currentDate.value);
    final all = unplannedRepo.getAllTasks();
    final todayStart = DateTime(currentDate.value.year, currentDate.value.month, currentDate.value.day);

    final overdue = all.where((t) {
      if (t.isCompleted) return false;
      final taskDay = DateTime(t.date.year, t.date.month, t.date.day);
      return taskDay.isBefore(todayStart);
    }).toList();

    tasks.assignAll(dayTasks);
    overdueTasks.assignAll(overdue);
    onTasksChangedCallback?.call();
  }

  Future<void> submitInline() async {
    final title = inlineController.text.trim();
    if (title.isEmpty) return;

    inlineController.clear();
    inlineFocus.unfocus();

    final task = UnplannedTask(
      id: const Uuid().v4(),
      title: title,
      date: currentDate.value,
      priority: TaskPriority.normal,
    );

    await unplannedRepo.addTask(task);
    loadTasks();
  }

  Future<void> toggleTask(String id) async {
    await unplannedRepo.toggleTaskCompletion(id);
    loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await unplannedRepo.deleteTask(id);
    loadTasks();
  }

  Future<void> postponeTaskToTomorrow(UnplannedTask task) async {
    final nextDay = task.date.add(const Duration(days: 1));
    final updated = task.copyWith(
      date: nextDay,
      originalDate: task.originalDate ?? task.date,
      postponedCount: task.postponedCount + 1,
    );

    await unplannedRepo.updateTask(updated);
    loadTasks();

    Get.snackbar(
      'Tâche reportée',
      'Tâche "${task.title}" reportée au lendemain ! ➡️',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> postponeAllOverdue() async {
    for (final task in overdueTasks) {
      final updated = task.copyWith(
        date: currentDate.value,
        originalDate: task.originalDate ?? task.date,
        postponedCount: task.postponedCount + 1,
      );
      await unplannedRepo.updateTask(updated);
    }
    loadTasks();

    Get.snackbar(
      'Tâches reportées',
      '${overdueTasks.length} tâche(s) reportée(s) à aujourd\'hui ! ➡️',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showConvertDialog(BuildContext context, UnplannedTask task) {
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.schedule_send_rounded, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Planifier dans l\'agenda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transformer "${task.title}" en créneau fixe dans votre emploi du temps :',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: startTime);
                          if (picked != null) {
                            setDialogState(() => startTime = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(
                          'Début : ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: endTime);
                          if (picked != null) {
                            setDialogState(() => endTime = picked);
                          }
                        },
                        icon: const Icon(Icons.timer_outlined, size: 16),
                        label: Text(
                          'Fin : ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  final newActivity = Activity(
                    id: const Uuid().v4(),
                    title: task.title,
                    description: task.description,
                    dayOfWeek: task.date.weekday,
                    startHour: startTime.hour,
                    startMinute: startTime.minute,
                    endHour: endTime.hour,
                    endMinute: endTime.minute,
                    category: task.category,
                    isCompleted: task.isCompleted,
                  );

                  await activityRepo.addActivity(newActivity);
                  await unplannedRepo.deleteTask(task.id);
                  loadTasks();

                  Get.snackbar(
                    'Planifiée',
                    'Activité "${task.title}" ajoutée à l\'emploi du temps !',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text('Planifier'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget réactif GetX affichant la liste interactive des tâches imprévues pour un jour donné
class UnplannedTaskListWidget extends StatelessWidget {
  final DateTime date;
  final bool initiallyExpanded;
  final VoidCallback? onTasksChanged;

  const UnplannedTaskListWidget({
    super.key,
    required this.date,
    this.initiallyExpanded = true,
    this.onTasksChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un tag unique basé sur la date pour l'injection GetX
    final tag = 'task_list_${date.year}_${date.month}_${date.day}';
    final controller = Get.put(
      UnplannedTaskListController(),
      tag: tag,
    );
    controller.init(date: date, initiallyExpanded: initiallyExpanded, onTasksChanged: onTasksChanged);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Obx(() {
      final tasks = controller.tasks;
      final overdueTasks = controller.overdueTasks;
      final pendingCount = tasks.where((t) => !t.isCompleted).length;
      final isExpanded = controller.isExpanded.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: pendingCount > 0
                ? Colors.amber.withValues(alpha: isDark ? 0.4 : 0.6)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: pendingCount > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (pendingCount > 0 ? Colors.amber : Colors.black).withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête cliquable pour replier/déplier
            InkWell(
              onTap: controller.toggleExpanded,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(18),
                bottom: Radius.circular(isExpanded ? 0 : 18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tâches Imprévues & Urgences',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '$pendingCount en cours',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      )
                    else if (tasks.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Toutes terminées 🎉',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                      tooltip: 'Ajout rapide',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.primary,
                      onPressed: () {
                        QuickTaskSheet.show(context, initialDate: date).then((_) => controller.loadTasks());
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Contenu déroulé
            if (isExpanded) ...[
              const Divider(height: 1),

              // Bannière de report
              if (isToday && overdueTasks.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${overdueTasks.length} tâche(s) inachevée(s) précédente(s)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Les reporter à aujourd\'hui pour ne rien perdre ?',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: controller.postponeAllOverdue,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Reporter ➡️', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),

              // Barre de saisie instantanée en ligne
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: controller.inlineController,
                          focusNode: controller.inlineFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.submitInline(),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '+ Saisie rapide (ex: Rappeler Marc)...',
                            hintStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            prefixIcon: const Icon(Icons.add_rounded, size: 18, color: Colors.amber),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: controller.submitInline,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Valider',
                    ),
                  ],
                ),
              ),

              // Liste des tâches
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  child: Text(
                    'Aucun imprévu enregistré pour ce jour.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskRowItem(
                      task: task,
                      onTap: () {
                        TaskCommentModal.show(context, taskId: task.id).then((_) => controller.loadTasks());
                      },
                      onToggle: () => controller.toggleTask(task.id),
                      onPostponeTomorrow: () => controller.postponeTaskToTomorrow(task),
                      onDelete: () => controller.deleteTask(task.id),
                      onConvert: () => controller.showConvertDialog(context, task),
                    );
                  },
                ),
            ],
          ],
        ),
      );
    });
  }
}

class _TaskRowItem extends StatelessWidget {
  final UnplannedTask task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onPostponeTomorrow;
  final VoidCallback onDelete;
  final VoidCallback onConvert;

  const _TaskRowItem({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onPostponeTomorrow,
    required this.onDelete,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isCompleted ? Colors.transparent : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            children: [
              // Case à cocher
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted ? theme.colorScheme.primary : (isDark ? Colors.grey[500]! : Colors.grey[400]!),
                      width: 1.8,
                    ),
                  ),
                  child: task.isCompleted ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 10),

              // Titre, description et badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (task.comments.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded, size: 10, color: Colors.blueAccent),
                                const SizedBox(width: 3),
                                Text(
                                  '${task.comments.length}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (task.postponedCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.forward_rounded, size: 10, color: Colors.orange),
                                const SizedBox(width: 2),
                                Text(
                                  'Reporté ${task.postponedCount}x',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (task.description != null && task.description!.isNotEmpty)
                          Expanded(
                            child: Text(
                              task.description!,
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de priorité
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priority.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(task.priority.icon, size: 11, color: task.priority.color),
                    const SizedBox(width: 2),
                    Text(
                      task.priority.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: task.priority.color),
                    ),
                  ],
                ),
              ),

              // Menu Popup d'actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'comments') onTap();
                  if (value == 'toggle') onToggle();
                  if (value == 'postpone') onPostponeTomorrow();
                  if (value == 'convert') onConvert();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'comments',
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Commentaires & Notes'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(task.isCompleted ? 'Marquer à faire' : 'Marquer fait'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'postpone',
                    child: Row(
                      children: [
                        Icon(Icons.forward_rounded, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reporter à demain'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'convert',
                    child: Row(
                      children: [
                        Icon(Icons.schedule_send_rounded, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Planifier dans l\'agenda'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
