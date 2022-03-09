import 'dart:ui';

import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension PresentationEmailExtension on PresentationEmail {

  List<Color> get avatarColors {
    return from?.first.avatarColors ?? AppColor.mapGradientColor.first;
  }

  int numberOfAllEmailAddress() => to.numberEmailAddress() + cc.numberEmailAddress() + bcc.numberEmailAddress();

  String getReceivedAt(String newLocale, {String? pattern}) {
    final emailTime = receivedAt;
    if (emailTime != null) {
      return emailTime.formatDate(
        pattern: pattern ?? emailTime.value.toLocal().toPattern(),
        locale: newLocale);
    }
    return '';
  }

  PresentationEmail toggleSelect() {
    return PresentationEmail(
        this.id,
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
        mailboxNames: mailboxNames,
        selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
    );
  }

  PresentationEmail toSelectedEmail({required SelectMode selectMode}) {
    return PresentationEmail(
      this.id,
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
      mailboxNames: mailboxNames,
      selectMode: selectMode,
    );
  }

  Email toEmail() {
    return Email(
        this.id,
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
        replyTo: replyTo
    );
  }

  String recipientsName() {
    final allEmailAddress = to.emailAddressToListString() + cc.emailAddressToListString() + bcc.emailAddressToListString();
    return allEmailAddress.isNotEmpty ? allEmailAddress.join(', ') : '';
  }

  Tuple3<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> generateRecipientsEmailAddressForComposer(
      EmailActionType? emailActionType,
      Role? mailboxRole
  ) {
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
          return Tuple3(to.asList() + from.asList(), cc.asList(), bcc.asList());
        }
      case EmailActionType.edit:
        return Tuple3(to.asList(), cc.asList(), bcc.asList());
      default:
        return Tuple3([], [], []);
    }
  }

  PresentationEmail toSearchPresentationEmail(Map<MailboxId, PresentationMailbox> mapMailboxes) {
    mailboxIds?.removeWhere((key, value) => !value);

    final listMailboxId = mailboxIds?.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

    final listMailboxName = listMailboxId
      ?.map((mailboxId) => mapMailboxes.containsKey(mailboxId) ? mapMailboxes[mailboxId]?.name : null)
      .where((mailboxName) => mailboxName != null)
      .toList();

    return PresentationEmail(
      this.id,
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
      mailboxNames: listMailboxName,
      selectMode: selectMode,
    );
  }
}