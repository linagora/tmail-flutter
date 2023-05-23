
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/sending_email_observer.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';

enum WorkerType {
  sendingEmail;

  WorkObserver usingObserver() {
    switch(this) {
      case WorkerType.sendingEmail:
        return SendingEmailObserver();
    }
  }

  String get iOSUniqueId {
    switch(this) {
      case WorkerType.sendingEmail:
        return WorkManagerConstants.sendingEmailUniqueId;
    }
  }
}