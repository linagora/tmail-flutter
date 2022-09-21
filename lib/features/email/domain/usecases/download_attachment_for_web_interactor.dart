import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/user_name.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadAttachmentForWebInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  DownloadAttachmentForWebInteractor(
      this.emailRepository,
      this.credentialRepository,
      this._accountRepository,
      this._authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute(
      DownloadTaskId taskId,
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      StreamController<Either<Failure, Success>> onReceiveController
  ) async* {
    try {
      yield Right<Failure, Success>(StartDownloadAttachmentForWeb(taskId, attachment));
      onReceiveController.add(Right(StartDownloadAttachmentForWeb(taskId, attachment)));

      // final currentAccount = await _accountRepository.getCurrentAccount();
      //
      // final bytesDownloaded = await Future.wait([
      //   if (currentAccount.authenticationType == AuthenticationType.oidc)
      //     _authenticationOIDCRepository.getStoredTokenOIDC(currentAccount.id)
      //   else
      //     credentialRepository.getAuthenticationInfoStored()
      // ], eagerError: true).then((List responses) async {
      //   AccountRequest accountRequest;
      //
      //   if (currentAccount.authenticationType == AuthenticationType.oidc) {
      //     final tokenOidc = responses.first as TokenOIDC;
      //     accountRequest = AccountRequest(
      //         token: tokenOidc.toToken(),
      //         authenticationType: AuthenticationType.oidc);
      //   } else {
      //     accountRequest = AccountRequest(
      //         userName: responses.first as UserName,
      //         password: responses.last as Password,
      //         authenticationType: AuthenticationType.basic);
      //   }

      final accountRequest = AccountRequest(
          userName: UserName("dat"),
          password: Password("pham"),
          authenticationType: AuthenticationType.basic);

        final bytesDownloaded = await emailRepository.downloadAttachmentForWeb(
            taskId,
            attachment,
            accountId,
            baseDownloadUrl,
            accountRequest,
            onReceiveController
        );
      // });

      yield Right<Failure, Success>(DownloadAttachmentForWebSuccess(
          taskId,
          attachment,
          bytesDownloaded));
    } catch (exception) {
      yield Left<Failure, Success>(DownloadAttachmentForWebFailure(
          taskId,
          exception));
    }
  }
}