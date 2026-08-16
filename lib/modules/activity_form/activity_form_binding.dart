import 'package:get/get.dart';
import 'activity_form_controller.dart';

/// Binding GetX pour le formulaire d'ajout et édition d'activité
class ActivityFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityFormController>(() => ActivityFormController());
  }
}
