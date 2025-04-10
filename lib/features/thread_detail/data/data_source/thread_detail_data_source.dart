import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

abstract class ThreadDetailDataSource {
  Future<List<EmailId>> getEmailIdsByThreadId(
    ThreadId threadId,
    AccountId accountId,
  );
}