
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/work_status.dart';

class SendingEmailObserver extends WorkObserver<Email> {

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  void handleFailureViewState(Failure failure) {
  }

  @override
  void handleSuccessViewState(Success success) {
  }

  @override
  WorkStatus observe(Email value) {
    return WorkStatus.failure;
  }
}