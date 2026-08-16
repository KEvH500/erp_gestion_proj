import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/controllers/base_controller.dart';
import '../../app/router/app_router.dart';
import '../../models/activity.dart';
import '../../models/unplanned_task.dart';

/// Contrôleur GetX pour la vue hebdomadaire
class WeekController extends BaseController {
  // Variables observables
  final weekOffset = 0.obs;
  final bottomNavIndex = 0.obs;
  final activitiesByDay = <int, List<Activity>>{}.obs;
  final allUnplannedTasks = <UnplannedTask>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Chargement et regroupement des activités et tâches pour la semaine sélectionnée
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final grouped = <int, List<Activity>>{};
      for (int i = 1; i <= 7; i++) {
        final date = getDateForDay(i);
        final dayActs = activityRepo.getActivitiesForDate(date);
        grouped[i] = dayActs;
      }
      activitiesByDay.assignAll(grouped);

      final unplanned = unplannedRepo.getAllTasks();
      allUnplannedTasks.assignAll(unplanned);
    } finally {
      isLoading.value = false;
    }
  }

  // Getters de dates calculées
  DateTime get startOfWeek {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    return currentMonday.add(Duration(days: weekOffset.value * 7));
  }

  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6));
  }

  DateTime getDateForDay(int dayOfWeek) {
    return startOfWeek.add(Duration(days: dayOfWeek - 1));
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get startFormatted => DateFormat('d MMM', 'fr_FR').format(startOfWeek);
  String get endFormatted => DateFormat('d MMM', 'fr_FR').format(endOfWeek);
  String get monthYearFormatted {
    final raw = DateFormat('MMMM yyyy', 'fr_FR').format(startOfWeek);
    return raw.isNotEmpty ? '${raw[0].toUpperCase()}${raw.substring(1)}' : raw;
  }

  String get weekSubtitle {
    if (weekOffset.value == 0) return 'Semaine en cours';
    if (weekOffset.value > 0) {
      return 'Dans ${weekOffset.value} semaine${weekOffset.value > 1 ? "s" : ""}';
    }
    return 'Il y a ${-weekOffset.value} semaine${-weekOffset.value > 1 ? "s" : ""}';
  }

  // Getters pré-calculés pour les listes par jour
  List<Activity> getActivitiesForDay(int dayOfWeek) {
    return activitiesByDay[dayOfWeek] ?? [];
  }

  List<UnplannedTask> getUnplannedTasksForDate(DateTime date) {
    return allUnplannedTasks.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  List<UnplannedTask> getPendingUnplannedTasksForDate(DateTime date) {
    return getUnplannedTasksForDate(date).where((t) => !t.isCompleted).toList();
  }

  int get todayUnplannedPendingCount {
    final today = DateTime.now();
    return getPendingUnplannedTasksForDate(today).length;
  }

  // Actions de navigation & calendrier
  void previousWeek() {
    weekOffset.value--;
    loadData();
  }

  void nextWeek() {
    weekOffset.value++;
    loadData();
  }

  void resetToCurrentWeek() {
    weekOffset.value = 0;
    loadData();
  }

  void onBottomNavSelected(int index) {
    bottomNavIndex.value = index;
    if (index == 0) {
      // Reste sur la semaine
    } else if (index == 1) {
      final today = DateTime.now();
      goToDay(today.weekday, today);
    } else if (index == 2) {
      Get.toNamed(Routes.GOALS)?.then((_) => loadData());
    } else if (index == 3) {
      Get.toNamed(Routes.SETTINGS);
    }
  }

  void goToDay(int dayOfWeek, DateTime date) {
    Get.toNamed(
      '${Routes.DAY}?day=$dayOfWeek&date=${date.toIso8601String()}',
    )?.then((_) => loadData());
  }

  void goToAddActivity([int? dayOfWeek]) {
    final date = dayOfWeek != null ? getDateForDay(dayOfWeek) : DateTime.now();
    Get.toNamed('${Routes.ACTIVITY_ADD}?date=${date.toIso8601String()}', arguments: date)?.then((_) => loadData());
  }

  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void goToDailyReport() {
    Get.toNamed(Routes.DAILY_REPORT);
  }

  Future<void> toggleActivityCompletion(String id) async {
    await activityRepo.toggleActivityCompletion(id);
    await loadData();
  }
}
