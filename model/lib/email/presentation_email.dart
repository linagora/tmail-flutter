
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class PresentationEmail with EquatableMixin {

  final EmailId id;
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

  PresentationEmail(
    this.id,
    {
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
    }
  );

  String getSenderName() => from?.first.asString() ?? '';

  String getAvatarText() {
    if (getSenderName().isNotEmpty) {
      final listWord = getSenderName().split(' ');
      if (listWord.length > 1) {
        final regexLetter = RegExp("([A-Za-z])");
        final firstLetterOfFirstWord = regexLetter.firstMatch(listWord[0].trim())?.group(0);
        final firstLetterOfSecondWord = regexLetter.firstMatch(listWord[1].trim())?.group(0);

        if (firstLetterOfFirstWord != null && firstLetterOfSecondWord != null) {
          return '${firstLetterOfFirstWord.toUpperCase()}${firstLetterOfSecondWord.toUpperCase()}';
        } else if (firstLetterOfFirstWord != null && firstLetterOfSecondWord == null) {
          return '${firstLetterOfFirstWord.toUpperCase()}${firstLetterOfFirstWord.toUpperCase()}';
        } else if (firstLetterOfFirstWord == null && firstLetterOfSecondWord != null) {
          return '${firstLetterOfSecondWord.toUpperCase()}${firstLetterOfSecondWord.toUpperCase()}';
        } else {
          return '';
        }
      } else {
        final regexLetter = RegExp("([A-Za-z])");
        final firstLetter = regexLetter.firstMatch(getSenderName().trim())?.group(0);
        return firstLetter != null ? '${firstLetter.toUpperCase()}${firstLetter.toUpperCase()}' : '';
      }
    }
    return '';
  }

  String getEmailTitle() => subject ?? '';

  String getPartialContent() => preview ?? '';

  bool get hasRead => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool get hasStarred => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  bool get withAttachments => hasAttachment == true;

  String get mailboxName => mailboxNames?.first?.name ?? '';

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
    hasAttachment
  ];
}