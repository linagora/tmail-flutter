import 'package:core/utils/app_logger.dart';
import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/caching/composer_cache_client.dart';
import 'package:tmail_ui_user/features/composer/data/extensions/composer_cache_extension.dart';
import 'package:tmail_ui_user/features/composer/data/extensions/composer_extension.dart';

class ComposerCacheManager {
  final ComposerCacheClient _composerCacheClient;

  ComposerCacheManager(this._composerCacheClient);

  Future<Composer?> getDraftComposer() async {
    try {
      final composer = await _composerCacheClient.getItem('composerDraft');
      return composer?.toComposer();
    } catch (e) {
      logError('ComposerCacheManager::getSelectedComposer(): $e');
      rethrow;
    }
  }

  Future<void> setDraftComposer(Composer composer) async {
    log('ComposerCacheManager::setSelectedComposer(): $_composerCacheClient');
    final composerCacheExist = await _composerCacheClient.isExistTable();
    if (composerCacheExist) {
      await _composerCacheClient.clearAllData();
    }
    await _composerCacheClient.insertItem('composerDraft', composer.toCache());
  }

  Future<void> clearAllDataDraftComposer() {
    log('ComposerCacheManager::clearAllDataDraftComposer():');
    return _composerCacheClient.clearAllData();
  }
}