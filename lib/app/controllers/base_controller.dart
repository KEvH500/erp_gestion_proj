import 'package:get/get.dart';
import '../../data/local/database.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/config_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/unplanned_task_repository.dart';
import '../../utils/notification_service.dart';

/// Superclasse de base abstraite pour l'ensemble des contrôleurs GetX.
/// Fournit un accès direct, centralisé et typé à la base Drift, aux repositories et services.
abstract class BaseController extends GetxController {
  /// Base de données Drift SQLite
  AppDatabase get db => Get.find<AppDatabase>();

  /// Repository des activités (Hive / Drift)
  IActivityRepository get activityRepo => Get.find<IActivityRepository>();

  /// Repository des tâches imprévues et urgences (Hive)
  IUnplannedTaskRepository get unplannedRepo => Get.find<IUnplannedTaskRepository>();

  /// Repository des objectifs et défis (Hive)
  IGoalRepository get goalRepo => Get.find<IGoalRepository>();

  /// Repository de configuration SQLite (jours, options de rappel)
  IConfigRepository get configRepo => Get.find<IConfigRepository>();

  /// Service de notifications locales
  NotificationService get notificationService => Get.find<NotificationService>();
}
