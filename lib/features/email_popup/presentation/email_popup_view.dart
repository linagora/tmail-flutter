import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/keyboard/keyboard_handler_wrapper.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email_popup/presentation/email_popup_controller.dart';

class EmailPopupView extends GetWidget<EmailPopupController> {
  const EmailPopupView({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardHandlerWrapper(
      focusNode: controller.keyboardFocusNode,
      onKeyDownEventAction: controller.onKeyDownEventAction,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          final emailId = controller.emailId.value;
          if (emailId == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return EmailView(
            emailId: emailId,
            isInsideThreadDetailView: false,
          );
        }),
      ),
    );
  }
}
