import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/bindings/initial_binding.dart';
import 'app/router/app_router.dart';
import 'data/repositories/activity_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/unplanned_task_repository.dart';
import 'models/activity.dart';
import 'models/recurrence_rule.dart';
import 'models/goal.dart';
import 'models/unplanned_task.dart';
import 'modules/settings/settings_controller.dart';
import 'theme/app_theme.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la localisation pour les dates en français
  await initializeDateFormatting('fr_FR', null);

  // 1. Initialisation de Hive pour Flutter
  await Hive.initFlutter();

  // 2. Enregistrement des adaptateurs générés et personnalisés
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ActivityCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ActivityAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(UnplannedTaskAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(GoalTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(GoalPeriodAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(GoalAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(RecurrenceFrequencyAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(RecurrenceEndTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(RecurrenceRuleAdapter());
  }

  // 3. Ouverture des boîtes Hive
  await Hive.openBox<Activity>(ActivityRepository.boxName);
  await Hive.openBox<UnplannedTask>(UnplannedTaskRepository.boxName);
  await Hive.openBox<Goal>(GoalRepository.boxName);
  await Hive.openBox(SettingsController.settingsBoxName);

  // 4. Initialisation du service de notifications locales et demande de permissions
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Emploi du temps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.INITIAL,
      initialBinding: InitialBinding(),
      getPages: AppRouter.routes,
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
    );
  }
}
