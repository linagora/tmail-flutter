import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadAttachmentsInteractor {
  final EmailRepository emailRepository;
  final CredentialRepository credentialRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AuthorizationInterceptors _authorizationInterceptors;

  DownloadAttachmentsInteractor(
    this.emailRepository,
    this.credentialRepository,
    this._accountRepository,
    this._authenticationOIDCRepository,
    this._authorizationInterceptors,
  );

  Stream<Either<Failure, Success>> execute(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl
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
        final taskIds = await emailRepository.downloadAttachments(
            attachments,
            accountId,
            baseDownloadUrl,
            accountRequest);

        yield Right<Failure, Success>(DownloadAttachmentsSuccess(taskIds));
      } else {
        yield Left<Failure, Success>(DownloadAttachmentsFailure(null));
      }
    } catch (exception) {
      log('DownloadAttachmentsInteractor::execute(): $exception');
      if (exception is DownloadAttachmentHasTokenExpiredException) {
        yield* _retryDownloadAttachments(
            accountId,
            baseDownloadUrl,
            attachments,
            exception.refreshToken);
      } else {
        yield Left<Failure, Success>(DownloadAttachmentsFailure(exception));
      }
    }
  }

  Stream<Either<Failure, Success>> _retryDownloadAttachments(
      AccountId accountId,
      String baseDownloadUrl,
      List<Attachment> attachments,
      String refreshToken) async* {
    log('DownloadAttachmentsInteractor::_retryDownloadAttachments(): $refreshToken');
    try {
      final accountCurrent = await _accountRepository.getCurrentAccount();
      final oidcConfig = await _authenticationOIDCRepository.getStoredOidcConfiguration();
      final newTokenOIDC = await _authenticationOIDCRepository.refreshingTokensOIDC(
          oidcConfig.clientId,
          oidcConfig.redirectUrl,
          oidcConfig.discoveryUrl,
          oidcConfig.scopes,
          refreshToken);

      await Future.wait([
        _authenticationOIDCRepository.persistTokenOIDC(newTokenOIDC),
        _accountRepository.deleteCurrentAccount(accountCurrent.id),
        _accountRepository.setCurrentAccount(Account(
          newTokenOIDC.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true,
          accountId: accountId,
          apiUrl: accountCurrent.apiUrl
        ))
      ]);

      _authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: newTokenOIDC.toToken(),
          newConfig: oidcConfig);

      final accountRequest = AccountRequest(
          token: newTokenOIDC.toToken(),
          authenticationType: AuthenticationType.oidc);

      final taskIds = await emailRepository.downloadAttachments(
          attachments,
          accountId,
          baseDownloadUrl,
          accountRequest);

      yield Right<Failure, Success>(DownloadAttachmentsSuccess(taskIds));
    } catch (e) {
      logError('RefreshTokenOIDCInteractor::execute(): $e');
      yield Left<Failure, Success>(DownloadAttachmentsFailure(e));
    }
  }
}