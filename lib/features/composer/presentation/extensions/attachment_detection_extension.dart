import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_text_detector.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension AttachmentDetectionExtension on ComposerController {

  List<String> validateAttachmentReminder({
    required String emailContent,
    required String emailSubject,
  }) {
    try {
      final fullContent = '$emailSubject $emailContent';
      final plainText = HtmlUtils.extractPlainText(fullContent);
      final keywords = AttachmentTextDetector.matchedKeywordsUnique(plainText);
      if (keywords.isEmpty) {
        return [];
      } else {
        return keywords;
      }
    } catch (e) {
      logError('$runtimeType::validateAttachmentReminder:Error $e');
      return [];
    }
  }

  Future<void> showAttachmentReminderModal({
    required BuildContext context,
    required List<String> keywords,
    required VoidCallback onConfirmAction,
    required VoidCallback onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);
    String formattedKeywords = keywords.map((k) => '"$k"').join(', ');
    log('$runtimeType::showAttachmentReminderModal:formattedKeywords = $formattedKeywords');
    return MessageDialogActionManager().showConfirmDialogAction(
      key: const Key('attachment_reminder_modal'),
      context,
      title: appLocalizations.attachmentReminderModalTitle,
      appLocalizations.attachmentReminderModalMessage(formattedKeywords),
      appLocalizations.sendMessage,
      cancelTitle: AppLocalizations.of(context).cancel,
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      onCloseButtonAction: popBack,
    );
  }
}
