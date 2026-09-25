import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_reload_cache_interactor.dart';

typedef ComposerReloadSnapshot = ({
  AccountId accountId,
  Session session,
  ComposerCache cache,
});

typedef ComposerReloadSnapshotBuilder = ComposerReloadSnapshot? Function();

class WebComposerReloadCacheHandler {
  final ComposerReloadSnapshotBuilder _buildSnapshot;
  final SaveComposerReloadCacheInteractor _saveCache;

  WebComposerReloadCacheHandler(this._buildSnapshot, this._saveCache);

  void saveBeforeUnload() {
    try {
      final snapshot = _buildSnapshot();
      if (snapshot == null) return;

      _saveCache.execute(snapshot.session, snapshot.accountId, snapshot.cache);
    } catch (error, stackTrace) {
      logWarning(
        'WebComposerReloadCacheHandler::saveBeforeUnload: '
        'error=${error.runtimeType}\n$stackTrace',
      );
    }
  }
}
