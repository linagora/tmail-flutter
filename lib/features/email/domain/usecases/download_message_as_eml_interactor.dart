import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_message_as_eml_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class DownloadMessageAsEMLInteractor {
  final EmailRepository _emailRepository;
  final CredentialRepository _credentialRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  DownloadMessageAsEMLInteractor(
    this._emailRepository,
    this._credentialRepository,
    this._accountRepository,
    this._authenticationOIDCRepository
  );

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    String baseDownloadUrl,
    Id blobId,
    String subjectEmail
  ) async* {
    try {
      yield Right<Failure, Success>(StartDownloadMessageAsEML());

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

      await _emailRepository.downloadMessageAsEML(
        accountId,
        baseDownloadUrl,
        accountRequest,
        blobId,
        subjectEmail);

      yield Right<Failure, Success>(DownloadMessageAsEMLSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(DownloadMessageAsEMLFailure(exception));
    }
  }
}