import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadAttachmentForWebInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;

  DownloadAttachmentForWebInteractor(this.emailRepository, this.credentialRepository);

  Stream<Either<Failure, Success>> execute(Attachment attachment, AccountId accountId, String baseDownloadUrl,) async* {
    try {
      final result = await Future.wait(
        [credentialRepository.getUserName(), credentialRepository.getPassword()],
        eagerError: true
      ).then((List responses) async {
        final accountRequest = AccountRequest(responses.first, responses.last);
        return await emailRepository.downloadAttachmentForWeb(
            attachment,
            accountId,
            baseDownloadUrl,
            accountRequest);
      });
      if (result) {
        yield Right<Failure, Success>(DownloadAttachmentForWebSuccess());
      } else {
        yield Left<Failure, Success>(DownloadAttachmentForWebFailure(null));
      }
    } catch (exception) {
      yield Left<Failure, Success>(DownloadAttachmentForWebFailure(exception));
    }
  }
}