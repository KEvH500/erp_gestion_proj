import 'package:get/get.dart';
import 'day_controller.dart';

/// Binding GetX pour la vue quotidienne
class DayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayController>(() => DayController());
  }
}
