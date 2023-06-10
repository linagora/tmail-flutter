
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

abstract class SendingQueueRepository {
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName);

  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail);

  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId);

  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds);

  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail);

  Future<List<SendingEmail>> updateMultipleSendingEmail(AccountId accountId, UserName userName, List<SendingEmail> newSendingEmails);
}