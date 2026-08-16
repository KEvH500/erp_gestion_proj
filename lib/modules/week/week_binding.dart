import 'package:get/get.dart';
import 'week_controller.dart';

/// Binding GetX pour la vue hebdomadaire
class WeekBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeekController>(() => WeekController());
  }
}
