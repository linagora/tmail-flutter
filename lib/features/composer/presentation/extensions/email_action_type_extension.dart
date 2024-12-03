
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/utc_date_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension EmailActionTypeExtension on EmailActionType {
  String getSubjectComposer(BuildContext? context, String subject) {
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyAll:
        if (subject.toLowerCase().startsWith('re:')) {
          return subject;
        } else {
          return context != null
            ? '${AppLocalizations.of(context).prefix_reply_email} $subject'
            : subject;
        }
      case EmailActionType.forward:
        if (subject.toLowerCase().startsWith('fwd:')) {
          return subject;
        } else {
          return context != null
            ? '${AppLocalizations.of(context).prefix_forward_email} $subject'
            : subject;
        }
      case EmailActionType.editDraft:
      case EmailActionType.editSendingEmail:
      case EmailActionType.reopenComposerBrowser:
        return subject;
      default:
        return '';
    }
  }

  String getToastMessageMoveToMailboxSuccess(BuildContext context, {String? destinationPath}) {
    switch(this) {
      case EmailActionType.moveToMailbox:
        return AppLocalizations.of(context).movedToFolder(destinationPath ?? '');
      case EmailActionType.moveToTrash:
        return AppLocalizations.of(context).moved_to_trash;
      case EmailActionType.moveToSpam:
        return AppLocalizations.of(context).marked_as_spam;
      case EmailActionType.unSpam:
        return AppLocalizations.of(context).marked_as_not_spam;
      default:
        return '';
    }
  }

  String? getHeaderEmailQuoted({
    required BuildContext context,
    required PresentationEmail presentationEmail
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyAll:
        final receivedAt = presentationEmail.receivedAt;
        final emailAddress = presentationEmail.from.listEmailAddressToString(isFullEmailAddress: true);
        return AppLocalizations.of(context).header_email_quoted(
          receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: locale),
          emailAddress
        );
      case EmailActionType.forward:
        var headerQuoted = '------- ${AppLocalizations.of(context).forwarded_message} -------'.addNewLineTag();

        final subject = presentationEmail.subject ?? '';
        final receivedAt = presentationEmail.receivedAt;
        final fromEmailAddress = presentationEmail.from.listEmailAddressToString(isFullEmailAddress: true);
        final toEmailAddress = presentationEmail.to.listEmailAddressToString(isFullEmailAddress: true);
        final ccEmailAddress = presentationEmail.cc.listEmailAddressToString(isFullEmailAddress: true);
        final bccEmailAddress = presentationEmail.bcc.listEmailAddressToString(isFullEmailAddress: true);
        final replyToEmailAddress = presentationEmail.replyTo.listEmailAddressToString(isFullEmailAddress: true);

        if (subject.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).subject_email}: ')
            .append(subject)
            .addNewLineTag();
        }
        if (receivedAt != null) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).date}: ')
            .append(receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: locale))
            .addNewLineTag();
        }
        if (fromEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).from_email_address_prefix}: ')
            .append(fromEmailAddress)
            .addNewLineTag();
        }
        if (toEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).to_email_address_prefix}: ')
            .append(toEmailAddress)
            .addNewLineTag();
        }
        if (ccEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).cc_email_address_prefix}: ')
            .append(ccEmailAddress)
            .addNewLineTag();
        }
        if (bccEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${AppLocalizations.of(context).bcc_email_address_prefix}: ')
            .append(bccEmailAddress)
            .addNewLineTag();
        }
        if (replyToEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
              .append('${AppLocalizations.of(context).reply_to_email_address_prefix}: ')
              .append(replyToEmailAddress)
              .addNewLineTag();
        }

        return headerQuoted;
      default:
        return null;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case EmailActionType.markAsUnread:
        return imagePaths.icUnreadEmail;
      case EmailActionType.unSpam:
        return imagePaths.icNotSpam;
      case EmailActionType.moveToSpam:
        return imagePaths.icSpam;
      case EmailActionType.createRule:
        return imagePaths.icQuickCreatingRule;
      case EmailActionType.unsubscribe:
        return imagePaths.icUnsubscribe;
      case EmailActionType.archiveMessage:
        return imagePaths.icMailboxArchived;
      case EmailActionType.downloadMessageAsEML:
        return imagePaths.icDownloadAttachment;
      default:
        return '';
    }
  }

  String getTitle(BuildContext context) {
    switch(this) {
      case EmailActionType.markAsUnread:
        return AppLocalizations.of(context).mark_as_unread;
      case EmailActionType.unSpam:
        return AppLocalizations.of(context).remove_from_spam;
      case EmailActionType.moveToSpam:
        return AppLocalizations.of(context).mark_as_spam;
      case EmailActionType.createRule:
        return AppLocalizations.of(context).quickCreatingRule;
      case EmailActionType.unsubscribe:
        return AppLocalizations.of(context).unsubscribe;
      case EmailActionType.archiveMessage:
        return AppLocalizations.of(context).archiveMessage;
      case EmailActionType.downloadMessageAsEML:
        return AppLocalizations.of(context).downloadMessageAsEML;
      default:
        return '';
    }
  }
}