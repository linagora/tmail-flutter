
import 'package:model/email/attachment.dart';
import 'package:model/upload/upload_request.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';

class ComposerRepositoryImpl extends ComposerRepository {

  final ComposerDataSource composerDataSource;

  ComposerRepositoryImpl(this.composerDataSource);

  @override
  Future<Attachment> uploadAttachment(UploadRequest uploadRequest) {
    return composerDataSource.uploadAttachment(uploadRequest);
  }
}