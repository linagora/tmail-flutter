import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmailInThreadDetailInfo with EquatableMixin {
  const EmailInThreadDetailInfo({
    required this.emailId,
    required this.keywords,
    required this.mailboxIds,
    required this.isValidToDisplay,
  });

  final EmailId emailId;
  final Map<KeyWordIdentifier, bool>? keywords;
  final Map<MailboxId, bool>? mailboxIds;
  final bool isValidToDisplay;

  @override
  List<Object?> get props => [emailId, keywords, mailboxIds, isValidToDisplay];

  EmailInThreadDetailInfo copyWith({
    EmailId? emailId,
    Map<KeyWordIdentifier, bool>? keywords,
    Map<MailboxId, bool>? mailboxIds,
    bool? isValidToDisplay,
  }) {
    return EmailInThreadDetailInfo(
      emailId: emailId ?? this.emailId,
      keywords: keywords ?? this.keywords,
      mailboxIds: mailboxIds ?? this.mailboxIds,
      isValidToDisplay: isValidToDisplay ?? this.isValidToDisplay,
    );
  }

  MailboxId? get mailboxIdContain {
    return mailboxIds?.entries
        .firstWhereOrNull((entry) => entry.value)
        ?.key;
  }
}