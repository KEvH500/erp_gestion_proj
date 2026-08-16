import 'package:hive_flutter/hive_flutter.dart';
import '../../models/goal.dart';

abstract class IGoalRepository {
  List<Goal> getAllGoals();
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Goal? getGoalById(String id);
  Future<void> toggleGoalCompletion(String id);
  Future<void> clearAllGoals();
}

class GoalRepository implements IGoalRepository {
  static const String boxName = 'goals';
  final Box<Goal> _box;

  GoalRepository([Box<Goal>? box])
      : _box = box ?? Hive.box<Goal>(boxName);

  @override
  List<Goal> getAllGoals() {
    return _box.values.toList();
  }

  @override
  Future<void> addGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  @override
  Goal? getGoalById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> toggleGoalCompletion(String id) async {
    final goal = _box.get(id);
    if (goal != null) {
      final updated = goal.copyWith(isCompleted: !goal.isCompleted);
      await _box.put(id, updated);
    }
  }

  @override
  Future<void> clearAllGoals() async {
    await _box.clear();
  }
}
