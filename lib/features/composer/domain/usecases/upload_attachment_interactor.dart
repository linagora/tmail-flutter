import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';

class UploadAttachmentInteractor {
  final ComposerRepository _composerRepository;

  UploadAttachmentInteractor(this._composerRepository);

  Stream<Either<Failure, Success>> execute(FileInfo fileInfo, AccountId accountId, Uri uploadUrl) async* {
    try {
      final result = await _composerRepository.uploadAttachment(
          UploadRequest(uploadUrl, accountId, fileInfo));
      yield Right<Failure, Success>(UploadAttachmentSuccess(result));
    } catch (e) {
      yield Left<Failure, Success>(UploadAttachmentFailure(e));
    }
  }
}