import 'package:hive_flutter/hive_flutter.dart';
import '../../models/unplanned_task.dart';

abstract class IUnplannedTaskRepository {
  List<UnplannedTask> getAllTasks();
  List<UnplannedTask> getTasksForDate(DateTime date);
  List<UnplannedTask> getTasksForDayOfWeek(int dayOfWeek);
  Future<void> addTask(UnplannedTask task);
  Future<void> updateTask(UnplannedTask task);
  Future<void> deleteTask(String id);
  UnplannedTask? getTaskById(String id);
  Future<void> toggleTaskCompletion(String id);
  Future<void> clearAllTasks();
}

class UnplannedTaskRepository implements IUnplannedTaskRepository {
  static const String boxName = 'unplanned_tasks';
  final Box<UnplannedTask> _box;

  UnplannedTaskRepository([Box<UnplannedTask>? box])
      : _box = box ?? Hive.box<UnplannedTask>(boxName);

  @override
  List<UnplannedTask> getAllTasks() {
    return _box.values.toList();
  }

  @override
  List<UnplannedTask> getTasksForDate(DateTime date) {
    final tasks = _box.values.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();

    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return tasks;
  }

  @override
  List<UnplannedTask> getTasksForDayOfWeek(int dayOfWeek) {
    return _box.values.where((task) => task.date.weekday == dayOfWeek).toList();
  }

  @override
  Future<void> addTask(UnplannedTask task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> updateTask(UnplannedTask task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  UnplannedTask? getTaskById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await _box.put(id, updated);
    }
  }

  @override
  Future<void> clearAllTasks() async {
    await _box.clear();
  }
}
