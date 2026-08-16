import 'package:flutter_test/flutter_test.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/goal.dart';
import 'package:erp_gestion_proj/models/unplanned_task.dart';

void main() {
  test('App models sanity test', () {
    final activity = Activity(
      id: 'act-1',
      title: 'Réunion projet',
      dayOfWeek: 1,
      startHour: 9,
      startMinute: 0,
      endHour: 10,
      endMinute: 30,
      category: ActivityCategory.travail,
    );

    final unplanned = UnplannedTask(
      id: 'unp-1',
      title: 'Appel client',
      date: DateTime(2026, 8, 16),
      priority: TaskPriority.urgent,
    );

    final goal = Goal(
      id: 'goal-1',
      title: 'Productivité',
      type: GoalType.fullTime,
      targetValue: 420.0,
    );

    expect(activity.durationInMinutes, 90);
    expect(unplanned.priority, TaskPriority.urgent);
    expect(goal.targetValue, 420.0);
  });
}
