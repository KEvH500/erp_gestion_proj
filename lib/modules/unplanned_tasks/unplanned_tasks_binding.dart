import 'package:get/get.dart';
import 'unplanned_tasks_controller.dart';

class UnplannedTasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnplannedTasksController>(() => UnplannedTasksController());
  }
}
