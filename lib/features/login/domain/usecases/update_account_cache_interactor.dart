import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/personal_account_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';

class UpdateAccountCacheInteractor {
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  UpdateAccountCacheInteractor(
    this._accountRepository,
    this._credentialRepository);

  Stream<Either<Failure, Success>> execute(Session session) async* {
    try{
      yield Right(UpdatingAccountCache());

      final futureValue = await Future.wait([
        _credentialRepository.getBaseUrl(),
        _accountRepository.getCurrentAccount(),
      ], eagerError: true);

      final baseUrl = futureValue[0] as Uri;
      final currentAccount = futureValue[1] as PersonalAccount;
      final apiUrl = session.getQualifiedApiUrl(
        baseUrl: currentAccount.authenticationType == AuthenticationType.basic
          ? baseUrl.origin
          : baseUrl.toString());

      await _accountRepository.setCurrentAccount(
        currentAccount.fromAccount(
          accountId: session.accountId,
          apiUrl: apiUrl,
          userName: session.username
        ));

      yield Right(UpdateAccountCacheSuccess(
        session: session,
        apiUrl: apiUrl));
    } catch(e) {
      yield Left(UpdateAccountCacheFailure(e));
    }
  }
}