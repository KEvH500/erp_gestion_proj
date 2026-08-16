import 'package:get/get.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/unplanned_task.dart';

/// Contrôleur GetX pour la gestion globale des tâches imprévues et urgences
class UnplannedTasksController extends BaseController {
  final selectedDate = DateTime.now().obs;
  final tasks = <UnplannedTask>[].obs;
  final overdueTasks = <UnplannedTask>[].obs;
  final filterCompleted = Rxn<bool>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is DateTime) {
      selectedDate.value = Get.arguments as DateTime;
    }
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final date = selectedDate.value;
      final dayTasks = unplannedRepo.getTasksForDate(date);
      final all = unplannedRepo.getAllTasks();

      final todayStart = DateTime(date.year, date.month, date.day);
      final overdue = all.where((t) {
        if (t.isCompleted) return false;
        final taskDay = DateTime(t.date.year, t.date.month, t.date.day);
        return taskDay.isBefore(todayStart);
      }).toList();

      tasks.assignAll(dayTasks);
      overdueTasks.assignAll(overdue);
    } finally {
      isLoading.value = false;
    }
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
    loadTasks();
  }

  void setFilterCompleted(bool? completed) {
    filterCompleted.value = completed;
  }

  List<UnplannedTask> get filteredTasks {
    if (filterCompleted.value == null) return tasks;
    return tasks.where((t) => t.isCompleted == filterCompleted.value).toList();
  }

  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  Future<void> toggleTask(String id) async {
    await unplannedRepo.toggleTaskCompletion(id);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await unplannedRepo.deleteTask(id);
    await loadTasks();
  }

  Future<void> postponeTaskToTomorrow(UnplannedTask task) async {
    final nextDay = task.date.add(const Duration(days: 1));
    final updated = task.copyWith(
      date: nextDay,
      originalDate: task.originalDate ?? task.date,
      postponedCount: task.postponedCount + 1,
    );
    await unplannedRepo.updateTask(updated);
    await loadTasks();
  }
}
