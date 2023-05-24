
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';

class SendingEmailObserver extends WorkObserver {

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  Future<void> observe(String taskId, Map<String, dynamic> inputData) async {
  }

  @override
  Future<void> bindDI() async {
  }
}