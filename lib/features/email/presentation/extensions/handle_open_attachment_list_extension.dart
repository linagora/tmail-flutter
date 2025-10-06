import 'package:core/presentation/extensions/scroll_controller_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';

extension HandleOpenAttachmentListExtension on SingleEmailController {
  void jumpToAttachmentList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attachmentListKey == null) return;

      threadDetailController?.scrollController?.scrollToWidgetTop(
        key: attachmentListKey!,
        padding: 70,
      );
    });
  }
}
