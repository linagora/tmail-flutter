import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

extension UpdateCurrentEmailsFlagsExtension on MailboxDashBoardController {
  void updateEmailFlagByEmailIds(
    List<EmailId> emailIds, {
    ReadActions? readAction,
    MarkStarAction? markStarAction,
    bool markAsAnswered = false,
    bool markAsForwarded = false,
  }) {
    if (readAction == null &&
        markStarAction == null &&
        !markAsAnswered &&
        !markAsForwarded) return;

    final currentEmails = dashboardRoute.value == DashboardRoutes.searchEmail
      ? listResultSearch
      : emailsInCurrentMailbox;

    if (currentEmails.isEmpty) return;

    for (var email in currentEmails) {
      if (!emailIds.contains(email.id)) continue;

      switch (readAction) {
        case ReadActions.markAsRead:
          _updateKeyword(email, KeyWordIdentifier.emailSeen, true);
          break;
        case ReadActions.markAsUnread:
          _updateKeyword(email, KeyWordIdentifier.emailSeen, false);
          break;
        default:
          break;
      }

      switch (markStarAction) {
        case MarkStarAction.markStar:
          _updateKeyword(email, KeyWordIdentifier.emailFlagged, true);
          break;
        case MarkStarAction.unMarkStar:
          _updateKeyword(email, KeyWordIdentifier.emailFlagged, false);
          break;
        default:
          break;
      }

      if (markAsAnswered) {
        _updateKeyword(email, KeyWordIdentifier.emailAnswered, true);
      }

      if (markAsForwarded) {
        _updateKeyword(email, KeyWordIdentifier.emailForwarded, true);
      }
    }

    currentEmails.refresh();
  }

  void _updateKeyword(
    PresentationEmail presentationEmail,
    KeyWordIdentifier keyword,
    bool value,
  ) {
    if (value) {
      presentationEmail.keywords?[keyword] = true;
    } else {
      presentationEmail.keywords?.remove(keyword);
    }
  }

  void updateEmailAnswered(EmailId emailId) {
    if (selectedEmail.value != null) {
      final newEmail = selectedEmail.value!.updateKeywords({
        KeyWordIdentifier.emailAnswered: true,
      });
      dispatchEmailUIAction(UpdatedEmailKeywordsAction(
        newEmail,
        KeyWordIdentifier.emailAnswered,
      ));
    }

    updateEmailFlagByEmailIds([emailId], markAsAnswered: true);
  }

  void updateEmailForwarded(EmailId emailId) {
    if (selectedEmail.value != null) {
      final newEmail = selectedEmail.value!.updateKeywords({
        KeyWordIdentifier.emailForwarded: true,
      });
      dispatchEmailUIAction(UpdatedEmailKeywordsAction(
        newEmail,
        KeyWordIdentifier.emailForwarded,
      ));
    }

    updateEmailFlagByEmailIds([emailId], markAsForwarded: true);
  }
}