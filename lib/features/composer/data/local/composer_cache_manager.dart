import 'package:core/utils/app_logger.dart';
import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/caching/composer_cache_client.dart';
import 'package:tmail_ui_user/features/composer/data/extensions/composer_cache_extension.dart';
import 'package:tmail_ui_user/features/composer/data/extensions/composer_extension.dart';

class ComposerCacheManager {
  final ComposerCacheClient _composerCacheClient;

  ComposerCacheManager(this._composerCacheClient);

  Future<Composer> getDraftComposer() async {
    try {
      final allComposers = await _composerCacheClient.getAll();
      return allComposers.first.toComposer();
    } catch (e) {
      logError('ComposerCacheManager::getSelectedComposer(): $e');
      rethrow;
    }
  }

  Future<void> setDraftComposer(Composer composer) {
    log('ComposerCacheManager::setSelectedComposer(): $_composerCacheClient');
    return _composerCacheClient.insertItem(composer.emailActionType.name, composer.toCache());
  }

  Future<void> clearAllDataDraftComposer() {
    log('ComposerCacheManager::clearAllDataDraftComposer():');
    return _composerCacheClient.clearAllData();
  }
}