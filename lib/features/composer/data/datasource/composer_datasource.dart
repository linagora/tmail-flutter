import 'package:model/model.dart';

abstract class ComposerDataSource {
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest);
}