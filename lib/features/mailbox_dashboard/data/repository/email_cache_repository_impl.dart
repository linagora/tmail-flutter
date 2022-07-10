import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/email_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/email_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/email_cache_repository.dart';

class EmailCacheRepositoryImpl extends EmailCacheRepository {

  final EmailCacheDataSource emailCacheDataSource;

  EmailCacheRepositoryImpl(this.emailCacheDataSource);

  @override
  EmailCache? getEmailCacheOnWeb() {
    return emailCacheDataSource.getEmailCacheOnWeb();
  }

  @override
  void removeEmailCacheOnWeb() {
    return emailCacheDataSource.removeEmailCacheOnWeb();
  }

  @override
  void saveEmailCacheOnWeb(Email email) {
    return emailCacheDataSource.saveEmailCacheOnWeb(email);
  }
}