import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class ExportAttachmentInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  ExportAttachmentInteractor(
    this.emailRepository,
    this.credentialRepository,
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
        accountRequest = AccountRequest(
            token: tokenOidc.toToken(),
            authenticationType: AuthenticationType.oidc);
      } else {
        final authenticationInfoCache = await credentialRepository.getAuthenticationInfoStored();
        if (authenticationInfoCache != null) {
          accountRequest = AccountRequest(
              userName: UserName(authenticationInfoCache.username),
              password: Password(authenticationInfoCache.password),
              authenticationType: AuthenticationType.basic);
        }
      }

      if (accountRequest != null) {
        final downloadedResponse = await emailRepository.exportAttachment(
            attachment,
            accountId,
            baseDownloadUrl,
            accountRequest,
            cancelToken);

        yield Right<Failure, Success>(ExportAttachmentSuccess(downloadedResponse));
      } else {
        yield Left<Failure, Success>(ExportAttachmentFailure(null));
      }
    } catch (exception) {
      log('ExportAttachmentInteractor::execute(): exception: $exception');
      yield Left<Failure, Success>(ExportAttachmentFailure(exception));
    }
  }
}