
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_content.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/media_type_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

class PresentationEmail with EquatableMixin {

  final EmailId? id;
  final Map<KeyWordIdentifier, bool>? keywords;
  final UnsignedInt? size;
  final UTCDate? receivedAt;
  final bool? hasAttachment;
  final String? preview;
  final String? subject;
  final UTCDate? sentAt;
  final Set<EmailAddress>? from;
  final Set<EmailAddress>? to;
  final Set<EmailAddress>? cc;
  final Set<EmailAddress>? bcc;
  final Set<EmailAddress>? replyTo;
  final Map<MailboxId, bool>? mailboxIds;
  final List<MailboxName?>? mailboxNames;
  final SelectMode selectMode;
  final Uri? routeWeb;
  final PresentationMailbox? mailboxContain;
  final List<EmailHeader>? emailHeader;
  final Set<EmailBodyPart>? htmlBody;
  final Map<PartId, EmailBodyValue>? bodyValues;

  PresentationEmail({
    this.id,
    this.keywords,
    this.size,
    this.receivedAt,
    this.hasAttachment,
    this.preview,
    this.subject,
    this.sentAt,
    this.from,
    this.to,
    this.cc,
    this.bcc,
    this.replyTo,
    this.mailboxIds,
    this.mailboxNames,
    this.selectMode = SelectMode.INACTIVE,
    this.routeWeb,
    this.mailboxContain,
    this.emailHeader,
    this.htmlBody,
    this.bodyValues,
  });

  String getSenderName() {
    if (from?.isNotEmpty == true) {
      return from?.first.asString() ?? '';
    } else {
      return '';
    }
  }

  String getAvatarText() {
    if (getSenderName().isNotEmpty) {
      return getSenderName().firstLetterToUpperCase;
    }
    return '';
  }

  String getEmailTitle() => subject?.trim() ?? '';

  String getPartialContent() => preview?.trim() ?? '';

  bool get hasRead => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool get hasStarred => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  bool get isDraft => keywords?.containsKey(KeyWordIdentifier.emailDraft) == true;

  bool get isAnswered => keywords?.containsKey(KeyWordIdentifier.emailAnswered) == true;

  bool get isForwarded => keywords?.containsKey(KeyWordIdentifier.emailForwarded) == true;

  bool get isAnsweredAndForwarded => isAnswered && isForwarded;

  bool get withAttachments => hasAttachment == true;

  String get mailboxName {
    if (mailboxNames?.isNotEmpty == true) {
      return mailboxNames?.first?.name ?? '';
    } else {
      return '';
    }
  }

  String get routeWebAsString => routeWeb.toString();

  bool get pushNotificationActivated => !isDraft && !hasRead;

  String getCreateTimeAt(String newLocale) {
    return DateFormat(sentAt?.value.toPattern(), newLocale).format(sentAt?.value ?? DateTime.now());
  }

  List<EmailContent> get emailContentList {
    final newHtmlBody = htmlBody
        ?.where((emailBody) => emailBody.partId != null && emailBody.type != null)
        .toList() ?? <EmailBodyPart>[];

    final mapHtmlBody = { for (var emailBody in newHtmlBody) emailBody.partId! : emailBody.type! };

    final emailContents = bodyValues?.entries
        .map((entries) => EmailContent(mapHtmlBody[entries.key].toEmailContentType(), entries.value.value))
        .toList();

    return emailContents ?? [];
  }

  @override
  List<Object?> get props => [
    id,
    subject,
    from,
    to,
    cc,
    bcc,
    keywords,
    size,
    receivedAt,
    sentAt,
    replyTo,
    preview,
    hasAttachment,
    mailboxIds,
    mailboxNames,
    selectMode,
    routeWeb,
    mailboxContain,
    emailHeader
  ];
}