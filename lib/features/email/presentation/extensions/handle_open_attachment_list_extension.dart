import 'package:core/presentation/extensions/scroll_controller_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';

extension HandleOpenAttachmentListExtension on SingleEmailController {
  void jumpToAttachmentList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      threadDetailController?.scrollController?.scrollToWidgetTop(
        key: attachmentListKey,
        padding: PlatformInfo.isMobile ? 90 : 70,
      );
    });
  }
}
