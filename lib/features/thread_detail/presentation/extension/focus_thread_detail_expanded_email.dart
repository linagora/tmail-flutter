import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension FocusThreadDetailExpandedEmail on ThreadDetailController {
  void focusExpandedEmail(EmailId emailId) {
    Future.delayed(const Duration(milliseconds: 200), () {
      final context = GlobalObjectKey(emailId.id.value).currentContext;
      if (context != null && context.mounted) {
        Scrollable.ensureVisible(context);
      }
    });
  }
}