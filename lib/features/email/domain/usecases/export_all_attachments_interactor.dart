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
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class ExportAllAttachmentsInteractor {
  const ExportAllAttachmentsInteractor(
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
    String outputFileName,
    {CancelToken? cancelToken}
  ) async* {
    try {
      yield Right(ExportingAllAttachments());
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
      
      final result = await _emailRepository.exportAllAttachments(
        accountId,
        emailId,
        baseDownloadAllUrl,
        outputFileName,
        accountRequest,
        cancelToken: cancelToken,
      );

      yield Right(ExportAllAttachmentsSuccess(result));
    } catch (e) {
      logError('ExportAllAttachmentsInteractor::execute():EXCEPTION: $e');
      yield Left(ExportAllAttachmentsFailure(exception: e));
    }
  }
}