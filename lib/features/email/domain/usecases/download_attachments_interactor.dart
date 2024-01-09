import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';

class DownloadAttachmentsInteractor {
  final EmailRepository _emailRepository;
  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AuthorizationInterceptors _authorizationInterceptors;

  DownloadAttachmentsInteractor(
    this._emailRepository,
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

      final taskIds = await _emailRepository.downloadAttachments(
        attachments,
        accountId,
        baseDownloadUrl,
        currentAccount
      );

      yield Right<Failure, Success>(DownloadAttachmentsSuccess(taskIds));
    } catch (exception) {
      logError('DownloadAttachmentsInteractor::execute(): $exception');
      if (exception is DownloadAttachmentHasTokenExpiredException &&
          exception.refreshToken.isNotEmpty) {
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
      final currentAccount = await _accountRepository.getCurrentAccount();

      final newTokenOIDC = await _authenticationOIDCRepository.refreshingTokensOIDC(
        currentAccount.tokenOidc!.oidcConfiguration,
        refreshToken
      );

      final newAccount = currentAccount.updateToken(newTokenOIDC);

      await _accountRepository.deleteCurrentAccount(currentAccount.id);
      await _accountRepository.setCurrentAccount(newAccount);

      _authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: newTokenOIDC,
        newConfig: newTokenOIDC.oidcConfiguration
      );

      final taskIds = await _emailRepository.downloadAttachments(
        attachments,
        accountId,
        baseDownloadUrl,
        newAccount
      );

      yield Right<Failure, Success>(DownloadAttachmentsSuccess(taskIds));
    } catch (e) {
      yield Left<Failure, Success>(DownloadAttachmentsFailure(e));
    }
  }
}