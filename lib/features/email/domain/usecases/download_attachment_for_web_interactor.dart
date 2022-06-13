import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/user_name.dart';
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
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl
  ) async* {
    try {
      final currentAccount = await _accountRepository.getCurrentAccount();

      final result = await Future.wait([
        if (currentAccount.authenticationType == AuthenticationType.oidc)
          _authenticationOIDCRepository.getStoredTokenOIDC(currentAccount.id)
        else
          ...[
            credentialRepository.getUserName(),
            credentialRepository.getPassword()
          ]
      ], eagerError: true).then((List responses) async {
        AccountRequest accountRequest;

        if (currentAccount.authenticationType == AuthenticationType.oidc) {
          final tokenOidc = responses.first as TokenOIDC;
          accountRequest = AccountRequest(
              token: tokenOidc.toToken(),
              authenticationType: AuthenticationType.oidc);
        } else {
          accountRequest = AccountRequest(
              userName: responses.first as UserName,
              password: responses.last as Password,
              authenticationType: AuthenticationType.basic);
        }

        return await emailRepository.downloadAttachmentForWeb(
            attachment,
            accountId,
            baseDownloadUrl,
            accountRequest);
      });

      if (result) {
        yield Right<Failure, Success>(DownloadAttachmentForWebSuccess());
      } else {
        yield Left<Failure, Success>(DownloadAttachmentForWebFailure(null));
      }
    } catch (exception) {
      log('DownloadAttachmentForWebInteractor::execute(): exception: $exception');
      yield Left<Failure, Success>(DownloadAttachmentForWebFailure(exception));
    }
  }
}