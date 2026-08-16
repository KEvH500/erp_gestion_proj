import 'package:flutter_test/flutter_test.dart';
import 'package:erp_gestion_proj/models/unplanned_task.dart';
import 'package:erp_gestion_proj/models/activity.dart';

void main() {
  group('UnplannedTask model tests', () {
    test('Create unplanned task with default values', () {
      final now = DateTime.now();
      final task = UnplannedTask(
        id: 'test-1',
        title: 'Appel client urgent',
        date: now,
      );

      expect(task.id, 'test-1');
      expect(task.title, 'Appel client urgent');
      expect(task.priority, TaskPriority.normal);
      expect(task.isCompleted, false);
      expect(task.category, ActivityCategory.autre);
      expect(task.isToday, true);
      expect(task.comments.isEmpty, true);
      expect(task.postponedCount, 0);
    });

    test('Priority properties check', () {
      expect(TaskPriority.urgent.label, 'Urgent');
      expect(TaskPriority.normal.label, 'Normal');
      expect(TaskPriority.low.label, 'Basse');
    });

    test('copyWith works properly with comments and postponement', () {
      final task = UnplannedTask(
        id: 'test-1',
        title: 'Tâche A',
        date: DateTime(2026, 8, 16),
        priority: TaskPriority.normal,
      );

      final updatedTask = task.copyWith(
        isCompleted: true,
        priority: TaskPriority.urgent,
        comments: ['[16/08 19:30] En attente du devis'],
        postponedCount: 1,
        date: DateTime(2026, 8, 17),
      );

      expect(updatedTask.id, 'test-1');
      expect(updatedTask.title, 'Tâche A');
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.priority, TaskPriority.urgent);
      expect(updatedTask.comments.length, 1);
      expect(updatedTask.comments.first, '[16/08 19:30] En attente du devis');
      expect(updatedTask.postponedCount, 1);
      expect(updatedTask.date.day, 17);
    });

    test('isOverdue check', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final overdueTask = UnplannedTask(
        id: 'test-overdue',
        title: 'Tâche d\'hier non finie',
        date: yesterday,
        isCompleted: false,
      );

      expect(overdueTask.isOverdue, true);

      final completedOverdueTask = overdueTask.copyWith(isCompleted: true);
      expect(completedOverdueTask.isOverdue, false);
    });
  });
}
