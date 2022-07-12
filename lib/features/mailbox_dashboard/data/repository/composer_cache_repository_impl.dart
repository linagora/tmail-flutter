import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class ComposerCacheRepositoryImpl extends ComposerCacheRepository {

  final ComposerCacheDataSource composerCacheDataSource;

  ComposerCacheRepositoryImpl(this.composerCacheDataSource);

  @override
  ComposerCache getComposerCacheOnWeb() {
    return composerCacheDataSource.getComposerCacheOnWeb();
  }

  @override
  void removeComposerCacheOnWeb() {
    return composerCacheDataSource.removeComposerCacheOnWeb();
  }

  @override
  void saveComposerCacheOnWeb(Email email) {
    return composerCacheDataSource.saveComposerCacheOnWeb(email);
  }
}