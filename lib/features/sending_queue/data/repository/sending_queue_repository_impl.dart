import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';

class SendingQueueRepositoryImpl extends SendingQueueRepository {

  final EmailHiveCacheDataSourceImpl _emailHiveCacheDataSourceImpl;

  SendingQueueRepositoryImpl(this._emailHiveCacheDataSourceImpl);

  @override
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName) {
    return _emailHiveCacheDataSourceImpl.getAllSendingEmails(accountId, userName);
  }
}