import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_attachment_request.dart';
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

  Stream<Either<Failure, Success>> execute(ExportAttachmentRequest request) async* {
    try {
      final currentAccount = await _accountRepository.getCurrentAccount();

      AccountRequest? accountRequest;

      if (currentAccount.authenticationType == AuthenticationType.oidc) {
        final tokenOidc = await _getTokenOidc(currentAccount.id, fallbackToken: request.fallbackToken);
        accountRequest = AccountRequest.withOidc(token: tokenOidc);
      } else {
        final authenticationInfoCache = await _credentialRepository.getAuthenticationInfoStored();
        accountRequest = AccountRequest.withBasic(
          userName: UserName(authenticationInfoCache.username),
          password: Password(authenticationInfoCache.password),
        );
      }

      final downloadedResponse = await _downloadRepository.exportAttachment(
        request.attachment,
        request.accountId,
        request.baseDownloadUrl,
        accountRequest,
        request.cancelToken,
      );

      yield Right<Failure, Success>(ExportAttachmentSuccess(downloadedResponse));
    } catch (exception) {
      logWarning('ExportAttachmentInteractor::execute(): exception: $exception');
      yield Left<Failure, Success>(ExportAttachmentFailure(exception));
    }
  }

  Future<TokenOIDC> _getTokenOidc(
    String accountId, {
    TokenOIDC? fallbackToken,
  }) async {
    try {
      return await _authenticationOIDCRepository.getStoredTokenOIDC(accountId);
    } catch (e) {
      if (fallbackToken != null) {
        logTrace('ExportAttachmentInteractor::_getTokenOidc(): '
            'storage failed, using in-memory token as fallback | error=${e.runtimeType}');
        _authenticationOIDCRepository.persistTokenOIDC(fallbackToken).catchError(
          (dynamic repairError) => logError(
            'ExportAttachmentInteractor::_getTokenOidc(): '
            'failed to repair token storage | error=${repairError.runtimeType}',
            exception: repairError,
          ),
        );
        return fallbackToken;
      }
      rethrow;
    }
  }
}