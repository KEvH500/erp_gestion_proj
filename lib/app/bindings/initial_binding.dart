import 'package:get/get.dart';
import '../../data/local/database.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/unplanned_task_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/config_repository.dart';
import '../../data/services/database_service.dart';
import '../../utils/notification_service.dart';

/// Binding initial global exécuté au lancement de l'application
/// Injecte la base Drift, les repositories et services de manière permanente (singleton)
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Base relationnelle Drift SQLite
    Get.put<AppDatabase>(AppDatabase(), permanent: true);

    // 2. Service de notifications & Base SQLite Config
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<DatabaseService>(DatabaseService(), permanent: true);

    // 3. Repositories
    Get.put<IActivityRepository>(ActivityRepository(), permanent: true);
    Get.put<IUnplannedTaskRepository>(UnplannedTaskRepository(), permanent: true);
    Get.put<IGoalRepository>(GoalRepository(), permanent: true);
    Get.put<IConfigRepository>(ConfigRepository(), permanent: true);
  }
}
