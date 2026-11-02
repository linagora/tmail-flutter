
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_email_header_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/smime_signature_status.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/smime_signature_constant.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';

extension EmailExtension on Email {

  SMimeSignatureStatus get sMimeStatus {
    final status = sMimeStatusHeaderParsed.isNotEmpty
      ? sMimeStatusHeaderParsed
      : headers?.toSet().sMimeStatus;
    log('EmailExtension::sMimeStatus: $status');
    if (status == SMimeSignatureConstant.GOOD_SIGNATURE) {
      return SMimeSignatureStatus.goodSignature;
    } else  if (status == SMimeSignatureConstant.BAD_SIGNATURE) {
      return SMimeSignatureStatus.badSignature;
    } else {
      return SMimeSignatureStatus.notSigned;
    }
  }

  bool checkEmailValidForThreadDetail(
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) =>
      checkEmailValidForThreadDetailAddresses(sentMailboxId, {ownEmailAddress});

  bool checkEmailValidForThreadDetailAddresses(
    MailboxId sentMailboxId,
    Set<String> meAddresses,
  ) {
    return id != null &&
        (!inSentMailbox(sentMailboxId) ||
            !fromMeAddresses(meAddresses) ||
            !recipientsHasMeAddresses(meAddresses));
  }

  bool inSentMailbox(MailboxId sentMailboxId) {
    return mailboxIds?[sentMailboxId] == true;
  }

  bool fromMe(String ownEmailAddress) => fromMeAddresses({ownEmailAddress});

  bool fromMeAddresses(Set<String> meAddresses) {
    return from?.any((emailAddress) => meAddresses.contains(emailAddress.emailAddress)) == true;
  }

  bool recipientsHasMe(String ownEmailAddress) =>
      recipientsHasMeAddresses({ownEmailAddress});

  bool recipientsHasMeAddresses(Set<String> meAddresses) {
    final recipients = {
      ...to ?? {},
      ...cc ?? {},
      ...bcc ?? {},
    };
    return recipients.any((emailAddress) => meAddresses.contains(emailAddress.emailAddress)) ==
        true;
  }

  Email toggleKeyword(KeyWordIdentifier keyword, bool remove) {
    return copyWith(
      keywords: remove
          ? keywords.withoutKeyword(keyword)
          : keywords.withKeyword(keyword),
    );
  }
}