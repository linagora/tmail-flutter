import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadAllAttachmentsForWebInteractor {
  const DownloadAllAttachmentsForWebInteractor(
    this._emailRepository,
    this._accountRepository,
    this._authenticationOIDCRepository,
    this.credentialRepository,
  );

  final EmailRepository _emailRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final CredentialRepository credentialRepository;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    Attachment attachment,
    DownloadTaskId taskId,
    StreamController<Either<Failure, Success>> onReceiveController,
    {CancelToken? cancelToken}
  ) async* {
    try {
      yield Right(StartDownloadAllAttachmentsForWeb(
        taskId,
        attachment,
      ));
      onReceiveController.add(Right(StartDownloadAllAttachmentsForWeb(
        taskId,
        attachment,
      )));
      final currentAccount = await _accountRepository.getCurrentAccount();
      AccountRequest accountRequest;
      if (currentAccount.authenticationType == AuthenticationType.oidc) {
        final tokenOidc = await _authenticationOIDCRepository.getStoredTokenOIDC(currentAccount.id);
        accountRequest = AccountRequest.withOidc(token: tokenOidc);
      } else {
        final authenticationInfoCache = await credentialRepository.getAuthenticationInfoStored();
        accountRequest = AccountRequest.withBasic(
          userName: UserName(authenticationInfoCache.username),
          password: Password(authenticationInfoCache.password),
        );
      }

      await _emailRepository.downloadAllAttachmentsForWeb(
        accountId,
        emailId,
        baseDownloadAllUrl,
        attachment.name!,
        accountRequest,
        taskId,
        onReceiveController,
        cancelToken: cancelToken
      );

      yield Right(DownloadAllAttachmentsForWebSuccess(taskId: taskId));
    } catch (e) {
      logError('DownloadAllAttachmentsForWebInteractor::execute():EXCEPTION: $e');
      yield Left(DownloadAllAttachmentsForWebFailure(exception: e, taskId: taskId));
    }
  }
}