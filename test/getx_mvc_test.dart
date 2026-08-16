import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:erp_gestion_proj/data/repositories/activity_repository.dart';
import 'package:erp_gestion_proj/data/repositories/unplanned_task_repository.dart';
import 'package:erp_gestion_proj/data/repositories/goal_repository.dart';
import 'package:erp_gestion_proj/data/repositories/config_repository.dart';
import 'package:erp_gestion_proj/data/services/database_service.dart';
import 'package:erp_gestion_proj/modules/week/week_controller.dart';
import 'package:erp_gestion_proj/modules/day/day_controller.dart';
import 'package:erp_gestion_proj/modules/goals/goals_controller.dart';
import 'package:erp_gestion_proj/modules/unplanned_tasks/unplanned_tasks_controller.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/recurrence_rule.dart';
import 'package:erp_gestion_proj/models/recurrence_exception.dart';
import 'package:erp_gestion_proj/models/unplanned_task.dart';
import 'package:erp_gestion_proj/models/goal.dart';
import 'package:erp_gestion_proj/services/recurrence_engine.dart';
import 'package:erp_gestion_proj/utils/notification_service.dart';

class FakeActivityRepository implements IActivityRepository {
  final List<Activity> _list = [];
  @override
  List<Activity> getAllActivities() => List.from(_list);
  @override
  List<Activity> getActivitiesForDate(DateTime date) {
    final activities = <Activity>[];
    for (final act in _list) {
      final occurrence = RecurrenceEngine.getOccurrenceForDate(
        activity: act,
        targetDate: date,
      );
      if (occurrence != null) {
        activities.add(occurrence);
      }
    }
    activities.sort((a, b) {
      final aStart = a.startHour * 60 + a.startMinute;
      final bStart = b.startHour * 60 + b.startMinute;
      return aStart.compareTo(bStart);
    });
    return activities;
  }
  @override
  List<Activity> getActivitiesForDay(int dayOfWeek) =>
      _list.where((a) => a.dayOfWeek == dayOfWeek).toList();
  @override
  Future<void> addActivity(Activity activity) async => _list.add(activity);
  @override
  Future<void> updateActivity(Activity activity) async {
    final idx = _list.indexWhere((a) => a.id == activity.id);
    if (idx != -1) _list[idx] = activity;
  }
  @override
  Future<void> deleteActivity(String id) async =>
      _list.removeWhere((a) => a.id == id);
  @override
  Activity? getActivityById(String id) =>
      _list.cast<Activity?>().firstWhere((a) => a?.id == id, orElse: () => null);
  @override
  Future<void> toggleActivityCompletion(String id) async {
    final a = getActivityById(id);
    if (a != null) {
      updateActivity(a.copyWith(isCompleted: !a.isCompleted));
    }
  }
  @override
  Future<void> clearAllActivities() async => _list.clear();

  @override
  Future<void> addRecurrenceException(String activityId, RecurrenceException exception) async {
    final a = getActivityById(activityId);
    if (a == null) return;
    final updatedExceptions = List<RecurrenceException>.from(a.exceptions)
      ..removeWhere((e) =>
          e.originalDate.year == exception.originalDate.year &&
          e.originalDate.month == exception.originalDate.month &&
          e.originalDate.day == exception.originalDate.day)
      ..add(exception);
    await updateActivity(a.copyWith(exceptions: updatedExceptions));
  }

  @override
  Future<void> removeRecurrenceException(String activityId, DateTime originalDate) async {
    final a = getActivityById(activityId);
    if (a == null) return;
    final updatedExceptions = List<RecurrenceException>.from(a.exceptions)
      ..removeWhere((e) =>
          e.originalDate.year == originalDate.year &&
          e.originalDate.month == originalDate.month &&
          e.originalDate.day == originalDate.day);
    await updateActivity(a.copyWith(exceptions: updatedExceptions));
  }

  @override
  Future<void> detachOccurrence(String activityId, DateTime originalDate, Activity detachedActivity) async {
    await addActivity(detachedActivity);
    final exception = RecurrenceException(
      taskId: activityId,
      originalDate: originalDate,
      isDetached: true,
      detachedTaskId: detachedActivity.id,
    );
    await addRecurrenceException(activityId, exception);
  }
}

class FakeUnplannedTaskRepository implements IUnplannedTaskRepository {
  final List<UnplannedTask> _list = [];
  @override
  List<UnplannedTask> getAllTasks() => List.from(_list);
  @override
  List<UnplannedTask> getTasksForDate(DateTime date) => _list
      .where((t) =>
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day)
      .toList();
  @override
  List<UnplannedTask> getTasksForDayOfWeek(int dayOfWeek) =>
      _list.where((t) => t.date.weekday == dayOfWeek).toList();
  @override
  Future<void> addTask(UnplannedTask task) async => _list.add(task);
  @override
  Future<void> updateTask(UnplannedTask task) async {
    final idx = _list.indexWhere((t) => t.id == task.id);
    if (idx != -1) _list[idx] = task;
  }
  @override
  Future<void> deleteTask(String id) async =>
      _list.removeWhere((t) => t.id == id);
  @override
  UnplannedTask? getTaskById(String id) =>
      _list.cast<UnplannedTask?>().firstWhere((t) => t?.id == id, orElse: () => null);
  @override
  Future<void> toggleTaskCompletion(String id) async {
    final t = getTaskById(id);
    if (t != null) {
      updateTask(t.copyWith(isCompleted: !t.isCompleted));
    }
  }
  @override
  Future<void> clearAllTasks() async => _list.clear();
}

class FakeGoalRepository implements IGoalRepository {
  final List<Goal> _list = [];
  @override
  List<Goal> getAllGoals() => List.from(_list);
  @override
  Future<void> addGoal(Goal goal) async => _list.add(goal);
  @override
  Future<void> updateGoal(Goal goal) async {
    final idx = _list.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _list[idx] = goal;
  }
  @override
  Future<void> deleteGoal(String id) async =>
      _list.removeWhere((g) => g.id == id);
  @override
  Goal? getGoalById(String id) =>
      _list.cast<Goal?>().firstWhere((g) => g?.id == id, orElse: () => null);
  @override
  Future<void> toggleGoalCompletion(String id) async {
    final g = getGoalById(id);
    if (g != null) {
      updateGoal(g.copyWith(isCompleted: !g.isCompleted));
    }
  }
  @override
  Future<void> clearAllGoals() async => _list.clear();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    Get.reset();
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<IActivityRepository>(FakeActivityRepository(), permanent: true);
    Get.put<IUnplannedTaskRepository>(FakeUnplannedTaskRepository(), permanent: true);
    Get.put<IGoalRepository>(FakeGoalRepository(), permanent: true);
    Get.put<IConfigRepository>(ConfigRepository(DatabaseService()), permanent: true);
  });

  group('GetX MVC WeekController tests', () {
    test('WeekController loads and navigates weeks', () async {
      final actRepo = Get.find<IActivityRepository>();
      final now = DateTime.now();
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));

      await actRepo.addActivity(Activity(
        id: 'act-1',
        title: 'Mathématiques',
        startDate: currentMonday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        category: ActivityCategory.cours,
        recurrenceRule: RecurrenceRule(
          id: 'r-1',
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        ),
      ));

      final controller = WeekController();
      controller.onInit();
      await controller.loadData();

      expect(controller.getActivitiesForDay(1).length, 1);
      expect(controller.getActivitiesForDay(1).first.title, 'Mathématiques');

      controller.nextWeek();
      expect(controller.weekOffset.value, 1);
      expect(controller.weekSubtitle.contains('Dans 1 semaine'), true);

      controller.resetToCurrentWeek();
      expect(controller.weekOffset.value, 0);
    });
  });

  group('GetX MVC DayController tests', () {
    test('DayController loads data for day', () async {
      final actRepo = Get.find<IActivityRepository>();
      final now = DateTime.now();
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));
      final currentTuesday = currentMonday.add(const Duration(days: 1));

      await actRepo.addActivity(Activity(
        id: 'act-2',
        title: 'Sport',
        startDate: currentTuesday,
        startHour: 14,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        category: ActivityCategory.sport,
      ));

      final controller = DayController();
      controller.selectedDate.value = currentTuesday;
      controller.selectedDay.value = 2;
      controller.onInit();
      await controller.loadDayData();

      expect(controller.activities.length, 1);
      expect(controller.activities.first.title, 'Sport');
      expect(controller.dayName, 'Mardi');
    });
  });

  group('GetX MVC GoalsController tests', () {
    test('GoalsController calculates progress dynamically', () async {
      final actRepo = Get.find<IActivityRepository>();
      final goalRepo = Get.find<IGoalRepository>();

      await goalRepo.addGoal(Goal(
        id: 'goal-1',
        title: '4h de cours',
        type: GoalType.fullTime,
        targetValue: 240.0, // 4h = 240 min
        category: ActivityCategory.cours,
      ));

      final now = DateTime.now();
      await actRepo.addActivity(Activity(
        id: 'act-3',
        title: 'Physique',
        startDate: now,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        category: ActivityCategory.cours,
        isCompleted: true,
      ));

      final controller = GoalsController();
      controller.onInit();
      await controller.loadGoals();

      expect(controller.goals.length, 1);
      expect(controller.goals.first.currentValue, 120.0); // 2h accomplies
      expect(controller.goals.first.progressPercentage, 0.5);
    });
  });

  group('GetX MVC UnplannedTasksController tests', () {
    test('UnplannedTasksController loads tasks and handles postponement', () async {
      final unplannedRepo = Get.find<IUnplannedTaskRepository>();
      final now = DateTime.now();

      await unplannedRepo.addTask(UnplannedTask(
        id: 'task-1',
        title: 'Appel client',
        date: now,
        priority: TaskPriority.urgent,
      ));

      final controller = UnplannedTasksController();
      controller.onInit();
      await controller.loadTasks();

      expect(controller.tasks.length, 1);
      expect(controller.pendingCount, 1);

      await controller.postponeTaskToTomorrow(controller.tasks.first);
      final postponed = unplannedRepo.getTaskById('task-1');
      expect(postponed?.postponedCount, 1);
      expect(controller.tasks.isEmpty, true);
    });
  });
}
