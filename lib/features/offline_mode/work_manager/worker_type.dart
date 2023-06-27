
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/sending_email_worker.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/worker.dart';

enum WorkerType {
  sendingEmail;

  Worker getWorker() {
    switch(this) {
      case WorkerType.sendingEmail:
        return SendingEmailWorker();
    }
  }

  String get iOSUniqueId {
    switch(this) {
      case WorkerType.sendingEmail:
        return WorkManagerConstants.sendingEmailUniqueId;
    }
  }
}