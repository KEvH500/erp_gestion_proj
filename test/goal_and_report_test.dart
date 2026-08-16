import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/goal.dart';
import 'package:erp_gestion_proj/models/daily_report.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  group('Goal model tests', () {
    test('Full-time goal progress calculation', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Travail 7h',
        type: GoalType.fullTime,
        targetValue: 420.0, // 7h
        currentValue: 210.0, // 3.5h
      );

      expect(goal.progressPercentage, 0.5);
      expect(goal.progressPercentageFormatted, '50%');
      expect(goal.progressDisplay, '3.5h / 7.0h');
      expect(goal.isCompleted, false);
    });

    test('Task count goal progress calculation', () {
      final goal = Goal(
        id: 'goal-2',
        title: '5 tâches',
        type: GoalType.taskCount,
        targetValue: 5.0,
        currentValue: 5.0,
      );

      expect(goal.progressPercentage, 1.0);
      expect(goal.progressPercentageFormatted, '100%');
      expect(goal.progressDisplay, '5 / 5 tâches');
    });

    test('Time-limited goal expiration check', () {
      final pastDeadline = DateTime.now().subtract(const Duration(hours: 1));
      final goal = Goal(
        id: 'goal-3',
        title: 'Urgence avant 16h',
        type: GoalType.timeLimited,
        targetValue: 1.0,
        deadline: pastDeadline,
        isCompleted: false,
      );

      expect(goal.isExpired, true);
    });
  });

  group('DailyReport model tests', () {
    test('DailyReport metrics and formatted text output', () {
      final now = DateTime(2026, 8, 16);
      final report = DailyReport(
        date: now,
        activitiesTotal: 4,
        activitiesCompleted: 3,
        plannedDurationMinutes: 240,
        completedDurationMinutes: 180,
        unplannedTasksTotal: 2,
        unplannedTasksCompleted: 2,
        goalsTotal: 3,
        goalsAchieved: 2,
        categoryDurationMinutes: {
          ActivityCategory.travail: 120,
          ActivityCategory.cours: 60,
        },
        score: 85,
        appreciation: 'Très Bonne Productivité 🚀',
        personalNotes: 'Journée très efficace.',
      );

      expect(report.activityCompletionRate, 0.75);
      expect(report.unplannedResolutionRate, 1.0);
      expect(report.totalCompletedTimeFormatted, '3h 00m');
      expect(report.totalPlannedTimeFormatted, '4h 00m');

      final text = report.toFormattedText();
      expect(text.contains('RAPPORT DE FIN DE JOURNÉE'), true);
      expect(text.contains('85 / 100'), true);
      expect(text.contains('Journée très efficace.'), true);
    });
  });
}
