import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

class EmailPopupController extends BaseController {
  final emailId = Rxn<EmailId>();
  late final FocusNode keyboardFocusNode;

  MailboxDashBoardController get mailboxDashBoardController =>
      Get.find<MailboxDashBoardController>();

  @override
  void onInit() {
    super.onInit();
    keyboardFocusNode = FocusNode();
    _parseEmailIdFromRoute();
    _initializeEmailBindings();
  }

  void _parseEmailIdFromRoute() {
    final emailIdParam = Get.parameters['id'];
    if (emailIdParam != null && emailIdParam.isNotEmpty) {
      emailId.value = EmailId(Id(emailIdParam));
    }
  }

  void _initializeEmailBindings() {
    if (emailId.value != null) {
      EmailBindings(currentEmailId: emailId.value).dependencies();
    }
  }

  void onKeyDownEventAction(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      closePopup();
    }
  }

  void closePopup() {
    if (PlatformInfo.isWeb) {
      html.window.close();
    }
  }

  @override
  void onClose() {
    keyboardFocusNode.dispose();
    super.onClose();
  }
}
