
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

abstract class SendingQueueRepository {
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName, {bool needToReopen = false});

  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail);

  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId, {bool needToReopen = false});

  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail, {bool needToReopen = false});
}