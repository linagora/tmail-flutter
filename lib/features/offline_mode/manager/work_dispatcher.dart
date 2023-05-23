
import 'package:tmail_ui_user/features/offline_mode/controller/work_scheduler_controller.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(WorkSchedulerController().handleBackgroundTask);
}
