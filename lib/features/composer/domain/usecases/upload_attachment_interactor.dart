import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class UploadAttachmentInteractor {
  final ComposerRepository _composerRepository;
  final CredentialRepository _credentialRepository;

  UploadAttachmentInteractor(this._composerRepository, this._credentialRepository);

  Stream<Either<Failure, Success>> execute(FileInfo fileInfo, AccountId accountId, Uri uploadUrl) async* {
    try {
      final result = await Future.wait(
          [_credentialRepository.getUserName(), _credentialRepository.getPassword()],
          eagerError: true
      ).then((List responses) async {
        final accountRequest = AccountRequest(responses.first, responses.last);
        return await _composerRepository.uploadAttachment(UploadRequest(uploadUrl, accountId, fileInfo, accountRequest));
      });
      yield Right<Failure, Success>(UploadAttachmentSuccess(result));
    } catch (e) {
      yield Left<Failure, Success>(UploadAttachmentFailure(e));
    }
  }
}