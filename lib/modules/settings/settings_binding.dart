import 'package:get/get.dart';
import 'settings_controller.dart';

/// Binding GetX pour les paramètres
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
