import 'package:hive_flutter/hive_flutter.dart';
import '../../models/activity.dart';

abstract class IActivityRepository {
  List<Activity> getAllActivities();
  List<Activity> getActivitiesForDay(int dayOfWeek);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);
  Activity? getActivityById(String id);
  Future<void> toggleActivityCompletion(String id);
  Future<void> clearAllActivities();
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
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    await _box.put(activity.id, activity);
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
    }
  }

  @override
  Future<void> clearAllActivities() async {
    await _box.clear();
  }
}
