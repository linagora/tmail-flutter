import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

abstract class ThreadDetailRepository {
  Future<List<EmailId>> getEmailIdsByThreadId(
    ThreadId threadId,
    Session session,
    AccountId accountId,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  );

  Future<List<Email>> getEmailsByIds(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds, {
    Properties? properties,
  });
}