import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/apply_to_visible_email_list_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

extension UpdateCurrentEmailsFlagsExtension on MailboxDashBoardController {
  void updateEmailFlagByEmailIds(
    List<EmailId> emailIds, {
    ReadActions? readAction,
    MarkStarAction? markStarAction,
    bool markAsAnswered = false,
    bool markAsForwarded = false,
    bool isLabelAdded = false,
    List<KeyWordIdentifier>? labelKeywords,
  }) {
    if (readAction == null &&
        markStarAction == null &&
        !markAsAnswered &&
        !markAsForwarded &&
        labelKeywords?.isNotEmpty != true) {
      return;
    }

    final emailIdsSet = emailIds.toSet();
    applyToVisibleEmailList(
      (currentEmails) => currentEmails.map((email) {
        if (!emailIdsSet.contains(email.id)) return email;

        return _updateEmailKeywords(
          email,
          readAction: readAction,
          markStarAction: markStarAction,
          markAsAnswered: markAsAnswered,
          markAsForwarded: markAsForwarded,
          isLabelAdded: isLabelAdded,
          labelKeywords: labelKeywords,
        );
      }).toList(),
    );
  }

  PresentationEmail _updateEmailKeywords(
    PresentationEmail presentationEmail, {
    ReadActions? readAction,
    MarkStarAction? markStarAction,
    required bool markAsAnswered,
    required bool markAsForwarded,
    required bool isLabelAdded,
    List<KeyWordIdentifier>? labelKeywords,
  }) {
    final keywordUpdates = <KeyWordIdentifier, bool>{
      if (readAction == ReadActions.markAsRead)
        KeyWordIdentifier.emailSeen: true,
      if (readAction == ReadActions.markAsUnread)
        KeyWordIdentifier.emailSeen: false,
      if (markStarAction == MarkStarAction.markStar)
        KeyWordIdentifier.emailFlagged: true,
      if (markStarAction == MarkStarAction.unMarkStar)
        KeyWordIdentifier.emailFlagged: false,
      if (markAsAnswered) KeyWordIdentifier.emailAnswered: true,
      if (markAsForwarded) KeyWordIdentifier.emailForwarded: true,
      for (final keyword in labelKeywords ?? <KeyWordIdentifier>[])
        keyword: isLabelAdded,
    };

    if (keywordUpdates.isEmpty) {
      return presentationEmail;
    }

    return presentationEmail.updateKeywords(keywordUpdates);
  }

  void updateEmailAnswered(EmailId emailId) {
    dispatchThreadDetailUIAction(UpdatedEmailKeywordsAction(
      emailId,
      KeyWordIdentifier.emailAnswered,
      true,
    ));
    // Reset threadDetailUIAction
    dispatchThreadDetailUIAction(ThreadDetailUIAction());

    updateEmailFlagByEmailIds([emailId], markAsAnswered: true);
  }

  void updateEmailForwarded(EmailId emailId) {
    dispatchThreadDetailUIAction(UpdatedEmailKeywordsAction(
      emailId,
      KeyWordIdentifier.emailForwarded,
      true,
    ));
    // Reset threadDetailUIAction
    dispatchThreadDetailUIAction(ThreadDetailUIAction());

    updateEmailFlagByEmailIds([emailId], markAsForwarded: true);
  }
}
