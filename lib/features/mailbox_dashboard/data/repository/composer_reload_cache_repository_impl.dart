import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_reload_cache_repository.dart';

class ComposerReloadCacheRepositoryImpl
    implements ComposerReloadCacheRepository {
  final ComposerSessionCacheDatasourceImpl _datasource;

  ComposerReloadCacheRepositoryImpl(this._datasource);

  @override
  void saveSync(Session session, AccountId accountId, ComposerCache cache) =>
      _datasource.saveComposerCacheSync(session, accountId, cache);
}
