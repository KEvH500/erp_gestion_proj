import 'package:get/get.dart';
import 'daily_report_controller.dart';

class DailyReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyReportController>(() => DailyReportController());
  }
}
