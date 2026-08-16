// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../../modules/week/week_binding.dart';
import '../../modules/week/week_view.dart';
import '../../modules/day/day_binding.dart';
import '../../modules/day/day_view.dart';
import '../../modules/activity_form/activity_form_binding.dart';
import '../../modules/activity_form/activity_form_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/goals/goals_binding.dart';
import '../../modules/goals/goals_view.dart';
import '../../modules/daily_report/daily_report_binding.dart';
import '../../modules/daily_report/daily_report_view.dart';
import '../../modules/unplanned_tasks/unplanned_tasks_binding.dart';
import '../../modules/unplanned_tasks/unplanned_tasks_view.dart';
import '../../modules/export/export_binding.dart';
import '../../modules/export/export_view.dart';

abstract class AppRoutes {
  static const WEEK = '/';
  static const DAY = '/day';
  static const ACTIVITY_ADD = '/activity/add';
  static const ACTIVITY_EDIT = '/activity/edit';
  static const SETTINGS = '/settings';
  static const GOALS = '/goals';
  static const DAILY_REPORT = '/daily-report';
  static const UNPLANNED_TASKS = '/unplanned-tasks';
  static const EXPORT = '/export';
}

typedef Routes = AppRoutes;

class AppRouter {
  AppRouter._();

  static const INITIAL = AppRoutes.WEEK;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.WEEK,
      page: () => const WeekView(),
      binding: WeekBinding(),
    ),
    GetPage(
      name: AppRoutes.DAY,
      page: () => const DayView(),
      binding: DayBinding(),
    ),
    GetPage(
      name: AppRoutes.ACTIVITY_ADD,
      page: () => const ActivityFormView(),
      binding: ActivityFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ACTIVITY_EDIT,
      page: () => const ActivityFormView(),
      binding: ActivityFormBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.GOALS,
      page: () => const GoalsView(),
      binding: GoalsBinding(),
    ),
    GetPage(
      name: AppRoutes.DAILY_REPORT,
      page: () => const DailyReportView(),
      binding: DailyReportBinding(),
    ),
    GetPage(
      name: AppRoutes.UNPLANNED_TASKS,
      page: () => const UnplannedTasksView(),
      binding: UnplannedTasksBinding(),
    ),
    GetPage(
      name: AppRoutes.EXPORT,
      page: () => const ExportView(),
      binding: ExportBinding(),
    ),
  ];
}
