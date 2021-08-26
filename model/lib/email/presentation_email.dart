
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:model/extensions/email_address_extension.dart';

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
      this.selectMode = SelectMode.INACTIVE
    }
  );

  String getSenderName() {
    if (from != null && from!.isNotEmpty) {
      return from!.first.asString();
    }
    return '';
  }

  String getAvatarText() {
    if (getSenderName().isNotEmpty) {
      return getSenderName()[0].toUpperCase();
    }
    return '';
  }

  String getEmailTitle() => subject != null ? subject! : '';

  String getPartialContent() => preview != null ? preview! : '';

  bool isUnReadEmail() => !(keywords?.containsKey(KeyWordIdentifier.emailSeen) == true);

  bool isFlaggedEmail() => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

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