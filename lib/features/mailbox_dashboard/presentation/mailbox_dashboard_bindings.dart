import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_bindings.dart';

class MailboxDashBoardBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => MailboxDashBoardController());

    MailboxBindings().dependencies();
    ThreadBindings().dependencies();
  }
}