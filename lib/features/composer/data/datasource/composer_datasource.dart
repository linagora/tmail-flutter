import 'package:model/composer/composer.dart';
import 'package:model/model.dart';

abstract class ComposerDataSource {
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest);
  Future<Composer> getDraftComposer();
  Future<void> setDraftComposer(Composer composer);
  Future<void> deleteDraftComposer();
}