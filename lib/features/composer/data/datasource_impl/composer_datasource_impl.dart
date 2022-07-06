import 'package:model/composer/composer.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/local/composer_cache_manager.dart';
import 'package:tmail_ui_user/features/composer/data/network/composer_api.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final ComposerAPI _composerAPI;
  final ComposerCacheManager _composerCacheManager;

  ComposerDataSourceImpl(this._composerAPI, this._composerCacheManager);

  @override
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest) {
    return Future.sync(() async {
      final uploadResponse = await _composerAPI.uploadAttachment(uploadRequest);
      return uploadResponse.toAttachmentFile(uploadRequest.fileInfo.fileName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteDraftComposer() {
    return _composerCacheManager.clearAllDataDraftComposer();
  }

  @override
  Future<Composer> getDraftComposer() {
    return _composerCacheManager.getDraftComposer();
  }

  @override
  Future<void> setDraftComposer(Composer composer) {
    return _composerCacheManager.setDraftComposer(composer);
  }
}