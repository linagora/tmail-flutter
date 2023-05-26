
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';

class SendingEmailObserver extends WorkObserver {

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  Future<void> observe(String taskId, Map<String, dynamic> inputData) async {
    log('SendingEmailObserver::observe():taskId: $taskId | inputData: $inputData');
    return Future.value();
  }

  @override
  Future<void> bindDI() async {
    log('SendingEmailObserver::bindDI(): ');
    return Future.value();
  }
}