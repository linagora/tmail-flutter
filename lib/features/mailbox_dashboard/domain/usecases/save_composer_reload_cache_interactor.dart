import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_reload_cache_repository.dart';

class SaveComposerReloadCacheInteractor {
  final ComposerReloadCacheRepository _repository;

  SaveComposerReloadCacheInteractor(this._repository);

  // Keep beforeunload synchronous; the caller handles storage errors.
  void execute(Session session, AccountId accountId, ComposerCache cache) =>
      _repository.saveSync(session, accountId, cache);
}
