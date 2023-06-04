
import 'package:tmail_ui_user/features/base/isolate/isolate_manager.dart';

class SendingQueueIsolateManager extends IsolateManager {

  @override
  String get isolateIdentityName => 'sending_queue_isolate';
}