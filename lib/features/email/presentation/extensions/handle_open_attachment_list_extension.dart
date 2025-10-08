import 'package:core/presentation/extensions/scroll_controller_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

extension HandleOpenAttachmentListExtension on SingleEmailController {
  void jumpToAttachmentList({
    required EmailId emailId,
    required int countAttachments,
    required double screenHeight,
    bool isDisplayAllAttachments = false,
  }) {
    final scrollController = threadDetailController?.scrollController;
    if (scrollController == null || !scrollController.hasClients) {
      logError(
          '$runtimeType::jumpToAttachmentList(): scrollController is null');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PlatformInfo.isWeb && attachmentListKey != null) {
        final context = attachmentListKey!.currentContext;
        if (context == null) return;

        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        final emailContentHeight =
            (screenHeight - 180).clamp(0.0, screenHeight).toDouble();

        final totalItems = isDisplayAllAttachments
            ? countAttachments + 1
            : EmailUtils.maxMobileVisibleAttachments + 1;

        final totalAttachmentsHeight =
            totalItems * EmailUtils.attachmentItemHeight +
                (totalItems - 1) * EmailUtils.attachmentItemSpacing;

        log('$runtimeType::jumpToAttachmentList(): totalAttachmentsHeight: $totalAttachmentsHeight, emailContentHeight: $emailContentHeight');
        scrollController.scrollToBottomWithPadding(
          padding: totalAttachmentsHeight < emailContentHeight
              ? 0
              : emailContentHeight,
        );
      }
    });
  }
}
