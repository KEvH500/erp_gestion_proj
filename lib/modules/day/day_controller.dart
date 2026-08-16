import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/controllers/base_controller.dart';
import '../../app/router/app_router.dart';
import '../../models/activity.dart';
import '../../models/unplanned_task.dart';

/// Contrôleur GetX pour la vue détaillée d'une journée
class DayController extends BaseController {
  final selectedDay = 1.obs;
  final selectedDate = DateTime.now().obs;
  final activities = <Activity>[].obs;
  final unplannedTasks = <UnplannedTask>[].obs;
  final isLoading = false.obs;

  final ScrollController scrollController = ScrollController();

  static const int startHour = 6;
  static const int endHour = 23;
  static const double hourHeight = 64.0;
  static const double timeColumnWidth = 56.0;

  @override
  void onInit() {
    super.onInit();
    _initParameters();
    loadDayData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _initParameters() {
    // Lecture des paramètres passés dans la route ou les arguments
    if (Get.parameters.containsKey('day')) {
      final dayParsed = int.tryParse(Get.parameters['day'] ?? '1');
      if (dayParsed != null && dayParsed >= 1 && dayParsed <= 7) {
        selectedDay.value = dayParsed;
      }
    }

    if (Get.parameters.containsKey('date')) {
      final dateParsed = DateTime.tryParse(Get.parameters['date'] ?? '');
      if (dateParsed != null) {
        selectedDate.value = dateParsed;
      }
    } else if (Get.arguments is DateTime) {
      selectedDate.value = Get.arguments as DateTime;
      selectedDay.value = selectedDate.value.weekday;
    } else {
      final now = DateTime.now();
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));
      selectedDate.value = currentMonday.add(Duration(days: selectedDay.value - 1));
    }
  }

  /// Chargement des activités et des tâches pour la journée sélectionnée
  Future<void> loadDayData() async {
    isLoading.value = true;
    try {
      final acts = activityRepo.getActivitiesForDate(selectedDate.value);
      activities.assignAll(acts);

      final unp = unplannedRepo.getTasksForDate(selectedDate.value);
      unplannedTasks.assignAll(unp);
    } finally {
      isLoading.value = false;
    }
  }

  // Getters
  String get dayName {
    switch (selectedDay.value) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Jour';
    }
  }

  String get formattedDate =>
      DateFormat('d MMMM yyyy', 'fr_FR').format(selectedDate.value);

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
  }

  int get pendingUnplannedCount =>
      unplannedTasks.where((t) => !t.isCompleted).length;

  List<UnplannedTask> get overdueTasks {
    final allTasks = unplannedRepo.getAllTasks();
    final todayStart = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    return allTasks.where((t) {
      if (t.isCompleted) return false;
      final taskDay = DateTime(t.date.year, t.date.month, t.date.day);
      return taskDay.isBefore(todayStart);
    }).toList();
  }

  DateTime getDateForDay(int day) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    return currentMonday.add(Duration(days: day - 1));
  }

  // Actions
  void selectDay(int day) {
    selectedDay.value = day;
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    selectedDate.value = currentMonday.add(Duration(days: day - 1));
    loadDayData();
  }

  Future<void> toggleActivityCompletion(String id) async {
    await activityRepo.toggleActivityCompletion(id);
    await loadDayData();
  }

  Future<void> deleteActivity(String id) async {
    await activityRepo.deleteActivity(id);
    await loadDayData();
  }

  void goToAddActivity() {
    Get.toNamed(
      '${Routes.ACTIVITY_ADD}?date=${selectedDate.value.toIso8601String()}',
      arguments: selectedDate.value,
    )?.then((_) => loadDayData());
  }

  void goToEditActivity(Activity activity) {
    Get.toNamed(
      Routes.ACTIVITY_EDIT,
      arguments: activity,
    )?.then((_) => loadDayData());
  }

  void goToDailyReport() {
    Get.toNamed(
      Routes.DAILY_REPORT,
      arguments: selectedDate.value,
    );
  }
}
