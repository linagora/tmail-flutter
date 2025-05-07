import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

abstract class ThreadDetailRepository {
  Future<List<EmailId>> getThreadById(
    ThreadId threadId,
    AccountId accountId,
  );
}