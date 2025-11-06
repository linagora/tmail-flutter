import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class ExportAttachmentInteractor {
  final DownloadRepository _downloadRepository;
  final CredentialRepository _credentialRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  ExportAttachmentInteractor(
    this._downloadRepository,
    this._credentialRepository,
    this._accountRepository,
    this._authenticationOIDCRepository,
  );

  Stream<Either<Failure, Success>> execute(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      CancelToken cancelToken
  ) async* {
    try {
      final currentAccount = await _accountRepository.getCurrentAccount();

      AccountRequest? accountRequest;

      if (currentAccount.authenticationType == AuthenticationType.oidc) {
        final tokenOidc = await _authenticationOIDCRepository.getStoredTokenOIDC(currentAccount.id);
        accountRequest = AccountRequest.withOidc(token: tokenOidc);
      } else {
        final authenticationInfoCache = await _credentialRepository.getAuthenticationInfoStored();
        accountRequest = AccountRequest.withBasic(
          userName: UserName(authenticationInfoCache.username),
          password: Password(authenticationInfoCache.password),
        );
      }

      final downloadedResponse = await _downloadRepository.exportAttachment(
        attachment,
        accountId,
        baseDownloadUrl,
        accountRequest,
        cancelToken
      );

      yield Right<Failure, Success>(ExportAttachmentSuccess(downloadedResponse));
    } catch (exception) {
      log('ExportAttachmentInteractor::execute(): exception: $exception');
      yield Left<Failure, Success>(ExportAttachmentFailure(exception));
    }
  }
}