
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';

abstract class SendingQueueRepository {
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName);
}