import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_all_attachments_request.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class ExportAllAttachmentsInteractor {
  const ExportAllAttachmentsInteractor(
    this._downloadRepository,
    this._accountRepository,
    this._authenticationOIDCRepository,
    this._credentialRepository,
  );

  final DownloadRepository _downloadRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final CredentialRepository _credentialRepository;

  Stream<Either<Failure, Success>> execute(ExportAllAttachmentsRequest request) async* {
    try {
      yield Right(ExportingAllAttachments());
      final currentAccount = await _accountRepository.getCurrentAccount();
      AccountRequest accountRequest;
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

      final result = await _downloadRepository.exportAllAttachments(
        request.accountId,
        request.emailId,
        request.baseDownloadAllUrl,
        request.outputFileName,
        accountRequest,
        request.cancelToken,
      );

      yield Right(ExportAllAttachmentsSuccess(result));
    } catch (e) {
      logWarning('ExportAllAttachmentsInteractor::execute():EXCEPTION: $e');
      yield Left(ExportAllAttachmentsFailure(exception: e));
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
        logTrace('ExportAllAttachmentsInteractor::_getTokenOidc(): '
            'storage failed, using in-memory token as fallback | error=${e.runtimeType}');
        _authenticationOIDCRepository.persistTokenOIDC(fallbackToken).catchError(
          (Object repairError) => logError(
            'ExportAllAttachmentsInteractor::_getTokenOidc(): '
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