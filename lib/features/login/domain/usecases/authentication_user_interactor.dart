import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';

class AuthenticationInteractor {
  final AuthenticationRepository authenticationRepository;
  final CredentialRepository credentialRepository;
  final AccountRepository _accountRepository;

  AuthenticationInteractor(this.authenticationRepository, this.credentialRepository, this._accountRepository);

  Future<Either<Failure, Success>> execute(Uri baseUrl, UserName userName, Password password) async {
    try {
      log('AuthenticationInteractor::execute(): $_accountRepository');
      final user = await authenticationRepository.authenticationUser(baseUrl, userName, password);
      await Future.wait([
        credentialRepository.saveBaseUrl(baseUrl),
        credentialRepository.storeAuthenticationInfo(
            AuthenticationInfoCache(userName.userName, password.value)),
        _accountRepository.setCurrentAccount(Account(
          userName.userName,
          AuthenticationType.basic,
          isSelected: true
        ))
      ]);
      return Right(AuthenticationUserViewState(user));
    } catch (e) {
      logError('AuthenticationInteractor::execute(): $e');
      return Left(AuthenticationUserFailure(e));
    }
  }
}