import 'dart:ui';

import 'package:core/data/constants/constant.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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

  int get countRecipients =>
      to.numberEmailAddress() +
      cc.numberEmailAddress() +
      bcc.numberEmailAddress();

  int getCountMailAddressWithoutMe(String userName) {
    final uniqueEmails = <String>{};
    final newTo = to ?? {};
    final newCc = cc ?? {};
    final newBcc = bcc ?? {};
    final newFrom = from ?? {};

    for (final email in <EmailAddress>[...newTo, ...newCc, ...newBcc, ...newFrom]) {
      if (email.emailAddress != userName) {
        uniqueEmails.add(email.emailAddress);
      }
    }

    return uniqueEmails.length;
  }

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
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail toSelectedEmail({required SelectMode selectMode}) {
    return PresentationEmail(
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  Email toEmail() {
    return Email(
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    );
  }

  String recipientsName() {
    final allEmailAddress = to.emailAddressToListString() + cc.emailAddressToListString() + bcc.emailAddressToListString();
    return allEmailAddress.isNotEmpty ? allEmailAddress.join(', ') : '';
  }

  PresentationEmail toSearchPresentationEmail(Map<MailboxId, PresentationMailbox> mapMailboxes) {
    mailboxIds?.removeWhere((key, value) => !value);

    final matchedMailbox = findMailboxContain(mapMailboxes);

    return PresentationEmail(
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
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
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail updateKeywords(Map<KeyWordIdentifier, bool> newKeywords) {
    final combinedMap = {...(keywords ?? {}), ...newKeywords};
    combinedMap.removeWhere((key, value) => !value);
    log('PresentationEmailExtension::updateKeywords:combinedMap = $combinedMap');
    return PresentationEmail(
      id: id,
      blobId: blobId,
      keywords: combinedMap,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  PresentationEmail syncPresentationEmail({PresentationMailbox? mailboxContain, Uri? routeWeb}) {
    return PresentationEmail(
      id: id,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
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

  String? _sanitizeSearchSnippet(String? searchSnippet) => searchSnippet
    ?.replaceAll('\r', '')
    .replaceAll('\n', '')
    .replaceAll('\t', '');
  String? get sanitizedSearchSnippetSubject => _sanitizeSearchSnippet(searchSnippetSubject);
  String? get sanitizedSearchSnippetPreview => _sanitizeSearchSnippet(searchSnippetPreview);
}