import 'package:get/get.dart';
import 'goals_controller.dart';

class GoalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoalsController>(() => GoalsController());
  }
}
