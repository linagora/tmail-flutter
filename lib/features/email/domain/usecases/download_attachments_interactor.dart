import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadAttachmentsInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;

  DownloadAttachmentsInteractor(this.emailRepository, this.credentialRepository);

  Stream<Either<Failure, Success>> execute(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl
  ) async* {
    try {
      final taskIds = await Future.wait(
          [credentialRepository.getUserName(), credentialRepository.getPassword()],
          eagerError: true
      ).then((List responses) async {
        final accountRequest = AccountRequest(
            userName: responses.first,
            password: responses.last,
            authenticationType: AuthenticationType.basic);
        return await emailRepository.downloadAttachments(
            attachments,
            accountId,
            baseDownloadUrl,
            accountRequest);
      });

      yield Right<Failure, Success>(DownloadAttachmentsSuccess(taskIds));
    } catch (e) {
      yield Left<Failure, Success>(DownloadAttachmentsFailure(e));
    }
  }
}