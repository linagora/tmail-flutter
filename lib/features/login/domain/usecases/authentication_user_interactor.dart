import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';

class AuthenticationInteractor {
  final AuthenticationRepository authenticationRepository;
  final CredentialRepository credentialRepository;
  final AccountRepository _accountRepository;

  AuthenticationInteractor(
    this.authenticationRepository,
    this.credentialRepository,
    this._accountRepository
  );

  Stream<Either<Failure, Success>> execute({Uri? baseUrl, UserName? userName, Password? password}) async* {
    try {
      yield Right(AuthenticationUserLoading());

      if (baseUrl != null && userName != null && password != null) {
        final user = await authenticationRepository.authenticationUser(baseUrl, userName, password);
        await Future.wait([
          credentialRepository.saveBaseUrl(baseUrl),
          credentialRepository.storeAuthenticationInfo(AuthenticationInfoCache(userName.value, password.value)),
          _accountRepository.setCurrentAccount(PersonalAccount(
            userName.value,
            AuthenticationType.basic,
            isSelected: true
          ))
        ]);
        yield Right(AuthenticationUserSuccess(user));
      } else if (baseUrl == null) {
        yield Left(AuthenticationUserFailure(CanNotFoundBaseUrl()));
      } else if (userName == null) {
        yield Left(AuthenticationUserFailure(CanNotFoundUserName()));
      } else if (password == null) {
        yield Left(AuthenticationUserFailure(CanNotFoundPassword()));
      } else {
        yield Left(AuthenticationUserFailure(null));
      }
    } catch (e) {
      logError('AuthenticationInteractor::execute(): $e');
      yield Left(AuthenticationUserFailure(e));
    }
  }
}