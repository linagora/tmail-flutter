import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';

class SendingQueueRepositoryImpl extends SendingQueueRepository {

  final EmailHiveCacheDataSourceImpl _emailHiveCacheDataSourceImpl;

  SendingQueueRepositoryImpl(this._emailHiveCacheDataSourceImpl);

  @override
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName, {bool needToReopen = false}) {
    return _emailHiveCacheDataSourceImpl.getAllSendingEmails(accountId, userName, needToReopen: needToReopen);
  }

  @override
  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId, {bool needToReopen = false}) {
    return _emailHiveCacheDataSourceImpl.deleteSendingEmail(accountId, userName, sendingId, needToReopen: needToReopen);
  }

  @override
  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail, {bool needToReopen = false}) {
    return _emailHiveCacheDataSourceImpl.updateSendingEmail(accountId, userName, newSendingEmail, needToReopen: needToReopen);
  }

  @override
  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    return _emailHiveCacheDataSourceImpl.storeSendingEmail(accountId, userName, sendingEmail);
  }
}