import 'dart:ui';

import 'package:core/data/constants/constant.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/eml_attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/utc_date_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

extension PresentationEmailExtension on PresentationEmail {

  List<Color> get avatarColors {
    if (from?.isNotEmpty == true) {
      return from!.first.avatarColors;
    } else {
      return AppColor.mapGradientColor.first;
    }
  }

  int numberOfAllEmailAddress() => to.numberEmailAddress() + cc.numberEmailAddress() + bcc.numberEmailAddress();

  String getReceivedAt(String newLocale, {String? pattern}) {
    final emailTime = receivedAt;
    if (emailTime != null) {
      return emailTime.formatDateToLocal(
        pattern: pattern ?? emailTime.value.toLocal().toPattern(),
        locale: newLocale);
    }
    return '';
  }

  Set<EmailAddress> get listEmailAddressSender => from.asSet()..addAll(replyTo.asSet());

  PresentationEmail toggleSelect() {
    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
      routeWeb: routeWeb,
      mailboxContain: mailboxContain,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail toSelectedEmail({required SelectMode selectMode}) {
    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode,
      routeWeb: routeWeb,
      mailboxContain: mailboxContain,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  Email toEmail() {
    return Email(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      htmlBody: htmlBody,
      bodyValues: bodyValues,
      mailboxIds: mailboxIds,
      headers: emailHeader?.toSet(),
      headerCalendarEvent: headerCalendarEvent
    );
  }

  String recipientsName() {
    final allEmailAddress = to.emailAddressToListString() + cc.emailAddressToListString() + bcc.emailAddressToListString();
    return allEmailAddress.isNotEmpty ? allEmailAddress.join(', ') : '';
  }

  Tuple3<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> generateRecipientsEmailAddressForComposer({
    required EmailActionType emailActionType,
    Role? mailboxRole
  }) {
    switch(emailActionType) {
      case EmailActionType.reply:
        if (mailboxRole == PresentationMailbox.roleSent) {
          return Tuple3(to.asList(), [], []);
        } else {
          final replyToAddress = replyTo.asList().isNotEmpty ? replyTo.asList() : from.asList();
          return Tuple3(replyToAddress, [], []);
        }
      case EmailActionType.replyAll:
        if (mailboxRole == PresentationMailbox.roleSent) {
          return Tuple3(to.asList(), cc.asList(), bcc.asList());
        } else {
          final senderReplyToAddress = replyTo.asList().isNotEmpty ? replyTo.asList() : from.asList();
          return Tuple3(to.asList() + senderReplyToAddress, cc.asList(), bcc.asList());
        }
      default:
        return Tuple3(to.asList(), cc.asList(), bcc.asList());
    }
  }

  PresentationEmail toSearchPresentationEmail(Map<MailboxId, PresentationMailbox> mapMailboxes) {
    mailboxIds?.removeWhere((key, value) => !value);

    final matchedMailbox = findMailboxContain(mapMailboxes);

    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode,
      routeWeb: routeWeb,
      mailboxContain: matchedMailbox,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationMailbox? findMailboxContain(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final newMailboxIds = mailboxIds;
    newMailboxIds?.removeWhere((key, value) => !value);

    if (newMailboxIds?.isNotEmpty == true) {
      final firstMailboxId = newMailboxIds!.keys.first;
      if (mapMailbox.containsKey(firstMailboxId)) {
        return mapMailbox[firstMailboxId];
      }
    }
    return null;
  }

  PresentationEmail withRouteWeb(Uri routeWeb) {
    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode,
      routeWeb: routeWeb,
      mailboxContain: mailboxContain,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail updateKeywords(Map<KeyWordIdentifier, bool>? newKeywords) {
    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: newKeywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode,
      routeWeb: routeWeb,
      mailboxContain: mailboxContain,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail syncPresentationEmail({PresentationMailbox? mailboxContain, Uri? routeWeb}) {
    return PresentationEmail(
      id: this.id,
      blobId: blobId,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      mailboxIds: mailboxIds,
      selectMode: selectMode,
      routeWeb: routeWeb,
      mailboxContain: mailboxContain,
      headerCalendarEvent: headerCalendarEvent
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  bool isBelongToOneOfTheMailboxes(List<MailboxId> mailboxIdsSource) {
    final mapMailboxIds = mailboxIds;
    mapMailboxIds?.removeWhere((key, value) => !value);

    if (mapMailboxIds?.isNotEmpty == true) {
      final listMailboxId = mapMailboxIds!.keys.toList();
      log('PresentationEmailExtension::isBelongToOneOfTheMailboxes():listMailboxId: $listMailboxId');
      final listMailboxIdValid = listMailboxId.where((mailboxId) => mailboxIdsSource.contains(mailboxId));
      log('PresentationEmailExtension::isBelongToOneOfTheMailboxes():listMailboxIdValid: $listMailboxIdValid');
      return listMailboxIdValid.isNotEmpty;
    }

    return false;
  }

  EMLAttachment createEMLAttachment() {
    return EMLAttachment(
      blobId: blobId,
      name: getEmailTitle().isEmpty ? '${blobId?.value}.eml' : '${getEmailTitle()}.eml',
      type: MediaType.parse(Constant.octetStreamMimeType)
    );
  }
}