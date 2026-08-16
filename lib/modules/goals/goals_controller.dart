import 'package:get/get.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/goal.dart';

/// Contrôleur GetX pour le suivi des objectifs
class GoalsController extends BaseController {
  final goals = <Goal>[].obs;
  final filterType = Rxn<GoalType>();
  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    isLoading.value = true;
    try {
      final rawGoals = goalRepo.getAllGoals();
      final activities = activityRepo.getAllActivities();
      final unplanned = unplannedRepo.getAllTasks();

      final dayOfWeek = selectedDate.value.weekday;
      final dayActivities = activities.where((a) => a.dayOfWeek == dayOfWeek && a.isCompleted).toList();
      final dayUnplanned = unplanned.where((t) {
        return t.date.year == selectedDate.value.year &&
            t.date.month == selectedDate.value.month &&
            t.date.day == selectedDate.value.day &&
            t.isCompleted;
      }).toList();

      final updated = rawGoals.map((goal) {
        if (goal.type == GoalType.fullTime) {
          int totalMins = 0;
          for (final a in dayActivities) {
            if (goal.category == null || a.category == goal.category) {
              totalMins += a.durationInMinutes;
            }
          }
          for (final t in dayUnplanned) {
            if (goal.category == null || t.category == goal.category) {
              totalMins += t.estimatedMinutes ?? 30;
            }
          }
          final completed = totalMins >= goal.targetValue;
          return goal.copyWith(currentValue: totalMins.toDouble(), isCompleted: completed);
        } else if (goal.type == GoalType.taskCount) {
          int count = dayActivities.length + dayUnplanned.length;
          final completed = count >= goal.targetValue;
          return goal.copyWith(currentValue: count.toDouble(), isCompleted: completed);
        }
        return goal;
      }).toList();

      goals.assignAll(updated);
    } finally {
      isLoading.value = false;
    }
  }

  List<Goal> get filteredGoals {
    if (filterType.value == null) return goals;
    return goals.where((g) => g.type == filterType.value).toList();
  }

  int get achievedGoalsCount =>
      goals.where((g) => g.progressPercentage >= 1.0).length;

  double get overallCompletionRate =>
      goals.isEmpty ? 0.0 : (achievedGoalsCount / goals.length);

  void setFilterType(GoalType? type) {
    filterType.value = type;
  }

  Future<void> toggleGoal(String id) async {
    await goalRepo.toggleGoalCompletion(id);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await goalRepo.deleteGoal(id);
    await loadGoals();
  }
}
