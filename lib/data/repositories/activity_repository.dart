import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../../models/activity.dart';
import '../../models/recurrence_exception.dart';
import '../../services/recurrence_engine.dart';
import '../../services/sync_service.dart';

abstract class IActivityRepository {
  List<Activity> getAllActivities();
  List<Activity> getActivitiesForDate(DateTime date);
  List<Activity> getActivitiesForDay(int dayOfWeek);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);
  Activity? getActivityById(String id);
  Future<void> toggleActivityCompletion(String id);
  Future<void> clearAllActivities();

  // Gestion des exceptions de récurrence
  Future<void> addRecurrenceException(String activityId, RecurrenceException exception);
  Future<void> removeRecurrenceException(String activityId, DateTime originalDate);
  Future<void> detachOccurrence(String activityId, DateTime originalDate, Activity detachedActivity);
}

class ActivityRepository implements IActivityRepository {
  static const String boxName = 'activities';
  final Box<Activity> _box;

  ActivityRepository([Box<Activity>? box])
      : _box = box ?? Hive.box<Activity>(boxName);

  @override
  List<Activity> getAllActivities() {
    return _box.values.toList();
  }

  @override
  List<Activity> getActivitiesForDate(DateTime date) {
    final activities = <Activity>[];
    for (final act in _box.values) {
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
  List<Activity> getActivitiesForDay(int dayOfWeek) {
    final activities = _box.values
        .where((activity) => activity.dayOfWeek == dayOfWeek)
        .toList();

    activities.sort((a, b) {
      final aStart = a.startHour * 60 + a.startMinute;
      final bStart = b.startHour * 60 + b.startMinute;
      return aStart.compareTo(bStart);
    });

    return activities;
  }

  @override
  Future<void> addActivity(Activity activity) async {
    await _box.put(activity.id, activity);
    if (Get.isRegistered<SyncService>()) {
      SyncService.to.setSynced(activity.id, false);
      SyncService.to.syncAll(activities: [activity], tasks: []);
    }
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    await _box.put(activity.id, activity);
    if (Get.isRegistered<SyncService>()) {
      SyncService.to.setSynced(activity.id, false);
      SyncService.to.syncAll(activities: [activity], tasks: []);
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    await _box.delete(id);
  }

  @override
  Activity? getActivityById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> toggleActivityCompletion(String id) async {
    final activity = _box.get(id);
    if (activity != null) {
      final updated = activity.copyWith(isCompleted: !activity.isCompleted);
      await _box.put(id, updated);
      if (Get.isRegistered<SyncService>()) {
        SyncService.to.setSynced(id, false);
        SyncService.to.syncAll(activities: [updated], tasks: []);
      }
    }
  }

  @override
  Future<void> clearAllActivities() async {
    await _box.clear();
  }

  @override
  Future<void> addRecurrenceException(String activityId, RecurrenceException exception) async {
    final activity = _box.get(activityId);
    if (activity == null) return;

    final updatedExceptions = List<RecurrenceException>.from(activity.exceptions)
      ..removeWhere((e) =>
          e.originalDate.year == exception.originalDate.year &&
          e.originalDate.month == exception.originalDate.month &&
          e.originalDate.day == exception.originalDate.day)
      ..add(exception);

    final updatedActivity = activity.copyWith(exceptions: updatedExceptions);
    await _box.put(activityId, updatedActivity);
  }

  @override
  Future<void> removeRecurrenceException(String activityId, DateTime originalDate) async {
    final activity = _box.get(activityId);
    if (activity == null) return;

    final updatedExceptions = List<RecurrenceException>.from(activity.exceptions)
      ..removeWhere((e) =>
          e.originalDate.year == originalDate.year &&
          e.originalDate.month == originalDate.month &&
          e.originalDate.day == originalDate.day);

    final updatedActivity = activity.copyWith(exceptions: updatedExceptions);
    await _box.put(activityId, updatedActivity);
  }

  @override
  Future<void> detachOccurrence(String activityId, DateTime originalDate, Activity detachedActivity) async {
    // 1. Ajouter la nouvelle activité détachée indépendante
    await addActivity(detachedActivity);

    // 2. Marquer l'occurrence originale comme détachée dans la série parente
    final exception = RecurrenceException(
      taskId: activityId,
      originalDate: originalDate,
      isDetached: true,
      detachedTaskId: detachedActivity.id,
    );

    await addRecurrenceException(activityId, exception);
  }
}
