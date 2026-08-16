import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/controllers/base_controller.dart';
import '../../models/activity.dart';
import '../../models/daily_report.dart';

/// Contrôleur GetX pour le rapport quotidien
class DailyReportController extends BaseController {
  final selectedDate = DateTime.now().obs;
  final report = Rxn<DailyReport>();
  final personalNotes = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is DateTime) {
      selectedDate.value = Get.arguments as DateTime;
    }
    loadReport();
  }

  Future<void> loadReport() async {
    isLoading.value = true;
    try {
      final date = selectedDate.value;
      final dayActivities = activityRepo.getActivitiesForDate(date);
      final unplanned = unplannedRepo.getAllTasks();
      final goals = goalRepo.getAllGoals();
      final dayUnplanned = unplanned.where((t) {
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day;
      }).toList();

      int plannedMinutes = 0;
      int completedMinutes = 0;
      final categoryDuration = <ActivityCategory, int>{};

      for (final a in dayActivities) {
        plannedMinutes += a.durationInMinutes;
        if (a.isCompleted) {
          completedMinutes += a.durationInMinutes;
          categoryDuration[a.category] =
              (categoryDuration[a.category] ?? 0) + a.durationInMinutes;
        }
      }

      int completedUnplanned = 0;
      for (final t in dayUnplanned) {
        if (t.isCompleted) {
          completedUnplanned++;
          final mins = t.estimatedMinutes ?? 30;
          completedMinutes += mins;
          categoryDuration[t.category] =
              (categoryDuration[t.category] ?? 0) + mins;
        }
      }

      int goalsAchieved = 0;
      for (final g in goals) {
        if (g.isCompleted) {
          goalsAchieved++;
        }
      }

      // Calcul du score global sur 100
      double actScore = dayActivities.isEmpty ? 50.0 : (dayActivities.where((a) => a.isCompleted).length / dayActivities.length) * 50.0;
      double unpScore = dayUnplanned.isEmpty ? 25.0 : (completedUnplanned / dayUnplanned.length) * 25.0;
      double goalScore = goals.isEmpty ? 25.0 : (goalsAchieved / goals.length) * 25.0;
      int totalScore = (actScore + unpScore + goalScore).round().clamp(0, 100);

      String appreciation;
      if (totalScore >= 90) {
        appreciation = 'Journée Exceptionnelle 🌟';
      } else if (totalScore >= 75) {
        appreciation = 'Très Bonne Productivité 🚀';
      } else if (totalScore >= 50) {
        appreciation = 'Objectifs en Bonne Voie 💪';
      } else {
        appreciation = 'Journée à Reprendre en Main 🎯';
      }

      report.value = DailyReport(
        date: date,
        activitiesTotal: dayActivities.length,
        activitiesCompleted: dayActivities.where((a) => a.isCompleted).length,
        plannedDurationMinutes: plannedMinutes,
        completedDurationMinutes: completedMinutes,
        unplannedTasksTotal: dayUnplanned.length,
        unplannedTasksCompleted: completedUnplanned,
        goalsTotal: goals.length,
        goalsAchieved: goalsAchieved,
        categoryDurationMinutes: categoryDuration,
        score: totalScore,
        appreciation: appreciation,
        personalNotes: personalNotes.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    loadReport();
  }

  void updatePersonalNotes(String notes) {
    personalNotes.value = notes;
    if (report.value != null) {
      report.value = report.value!.copyWith(personalNotes: notes);
    }
  }

  Future<void> copyReportToClipboard() async {
    if (report.value == null) return;
    await Clipboard.setData(ClipboardData(text: report.value!.toFormattedText()));
    Get.snackbar(
      'Copié ! 📋',
      'Le rapport de fin de journée a été copié dans le presse-papiers.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
