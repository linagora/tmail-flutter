
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/utc_date_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension EmailActionTypeExtension on EmailActionType {
  String getSubjectComposer(BuildContext? context, String subject) {
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
        if (subject.toLowerCase().startsWith('re:')) {
          return subject;
        } else {
          return context != null
            ? '${AppLocalizations.of(context).prefix_reply_email} $subject'
            : 'Re: $subject';
        }
      case EmailActionType.forward:
        if (subject.toLowerCase().startsWith('fwd:')) {
          return subject;
        } else {
          return context != null
            ? '${AppLocalizations.of(context).prefix_forward_email} $subject'
            : 'Fwd: $subject';
        }
      case EmailActionType.editDraft:
      case EmailActionType.editSendingEmail:
      case EmailActionType.reopenComposerBrowser:
      case EmailActionType.editAsNewEmail:
      case EmailActionType.composeFromMailtoUri:
      case EmailActionType.composeFromUnsubscribeMailtoLink:
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
    required Locale locale,
    required AppLocalizations appLocalizations,
    required PresentationEmail presentationEmail
  }) {
    final languageTag = locale.toLanguageTag();
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
        final receivedAt = presentationEmail.receivedAt;
        final emailAddress = presentationEmail.from.toEscapeHtmlStringUseCommaSeparator();
        return appLocalizations.header_email_quoted(
          receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: languageTag),
          emailAddress
        );
      case EmailActionType.forward:
        var headerQuoted = '------- ${appLocalizations.forwarded_message} -------'.addNewLineTag();

        final subject = presentationEmail.subject?.escapeLtGtHtmlString() ?? '';
        final receivedAt = presentationEmail.receivedAt;
        final fromEmailAddress = presentationEmail.from.toEscapeHtmlStringUseCommaSeparator();
        final toEmailAddress = presentationEmail.to.toEscapeHtmlStringUseCommaSeparator();
        final ccEmailAddress = presentationEmail.cc.toEscapeHtmlStringUseCommaSeparator();
        final bccEmailAddress = presentationEmail.bcc.toEscapeHtmlStringUseCommaSeparator();
        final replyToEmailAddress = presentationEmail.replyTo.toEscapeHtmlStringUseCommaSeparator();

        if (subject.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.subject_email}: ')
            .append(subject)
            .addNewLineTag();
        }
        if (receivedAt != null) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.date}: ')
            .append(receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: languageTag))
            .addNewLineTag();
        }
        if (fromEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.from_email_address_prefix}: ')
            .append(fromEmailAddress)
            .addNewLineTag();
        }
        if (toEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.to_email_address_prefix}: ')
            .append(toEmailAddress)
            .addNewLineTag();
        }
        if (ccEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.cc_email_address_prefix}: ')
            .append(ccEmailAddress)
            .addNewLineTag();
        }
        if (bccEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
            .append('${appLocalizations.bcc_email_address_prefix}: ')
            .append(bccEmailAddress)
            .addNewLineTag();
        }
        if (replyToEmailAddress.isNotEmpty) {
          headerQuoted = headerQuoted
              .append('${appLocalizations.reply_to_email_address_prefix}: ')
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
      case EmailActionType.editAsNewEmail:
        return imagePaths.icEdit;
      case EmailActionType.openInNewTab:
        return imagePaths.icOpenInNewTab;
      case EmailActionType.printAll:
        return imagePaths.icPrinter;
      case EmailActionType.forward:
        return imagePaths.icForward;
      case EmailActionType.replyAll:
        return imagePaths.icReplyAll;
      case EmailActionType.replyToList:
        return imagePaths.icReply;
      case EmailActionType.moveToMailbox:
        return imagePaths.icMoveEmail;
      case EmailActionType.markAsStarred:
        return imagePaths.icStar;
      case EmailActionType.unMarkAsStarred:
        return imagePaths.icUnStar;
      case EmailActionType.moveToTrash:
      case EmailActionType.deletePermanently:
        return imagePaths.icDeleteComposer;
      default:
        return '';
    }
  }

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case EmailActionType.markAsUnread:
        return appLocalizations.mark_as_unread;
      case EmailActionType.unSpam:
        return appLocalizations.remove_from_spam;
      case EmailActionType.moveToSpam:
        return appLocalizations.mark_as_spam;
      case EmailActionType.createRule:
        return appLocalizations.quickCreatingRule;
      case EmailActionType.unsubscribe:
        return appLocalizations.unsubscribe;
      case EmailActionType.archiveMessage:
        return appLocalizations.archiveMessage;
      case EmailActionType.downloadMessageAsEML:
        return appLocalizations.downloadMessageAsEML;
      case EmailActionType.editAsNewEmail:
        return appLocalizations.editAsNewEmail;
      case EmailActionType.openInNewTab:
        return appLocalizations.openInNewTab;
      case EmailActionType.printAll:
        return appLocalizations.printAll;
      case EmailActionType.forward:
        return appLocalizations.forward;
      case EmailActionType.replyAll:
        return appLocalizations.reply_all;
      case EmailActionType.replyToList:
        return appLocalizations.replyToList;
      case EmailActionType.moveToMailbox:
        return appLocalizations.move_message;
      case EmailActionType.markAsStarred:
        return appLocalizations.mark_as_starred;
      case EmailActionType.unMarkAsStarred:
        return appLocalizations.not_starred;
      case EmailActionType.moveToTrash:
        return appLocalizations.move_to_trash;
      case EmailActionType.deletePermanently:
        return appLocalizations.delete_permanently;
      default:
        return '';
    }
  }

  Color getPopupMenuIconColor() {
    switch(this) {
      case EmailActionType.deletePermanently:
        return AppColor.redFF3347;
      default:
        return AppColor.steelGrayA540;
    }
  }

  Color getPopupMenuTitleColor() {
    switch(this) {
      case EmailActionType.deletePermanently:
        return AppColor.redFF3347;
      default:
        return Colors.black;
    }
  }
}