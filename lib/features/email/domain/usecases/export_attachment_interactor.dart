import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class ExportAttachmentInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;

  ExportAttachmentInteractor(this.emailRepository, this.credentialRepository);

  Stream<Either<Failure, Success>> execute(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      CancelToken cancelToken
  ) async* {
    try {
      final filePath = await Future.wait(
        [credentialRepository.getUserName(), credentialRepository.getPassword()],
        eagerError: true
      ).then((List responses) async {
        final accountRequest = AccountRequest(responses.first, responses.last);
        return await emailRepository.exportAttachment(
            attachment,
            accountId,
            baseDownloadUrl,
            accountRequest,
            cancelToken);
      });
      yield Right<Failure, Success>(ExportAttachmentSuccess(filePath));
    } catch (exception) {
      yield Left<Failure, Success>(ExportAttachmentFailure(exception));
    }
  }
}