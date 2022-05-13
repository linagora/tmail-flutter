import 'package:model/model.dart';

abstract class ComposerRepository {
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest);
}