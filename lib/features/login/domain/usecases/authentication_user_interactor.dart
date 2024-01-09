import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/basic_auth.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';

class AuthenticationInteractor {
  final AuthenticationRepository authenticationRepository;
  final AccountRepository _accountRepository;

  AuthenticationInteractor(
    this.authenticationRepository,
    this._accountRepository
  );

  Stream<Either<Failure, Success>> execute({
    required Uri baseUrl,
    required UserName userName,
    required Password password
  }) async* {
    try {
      yield Right(AuthenticationUserLoading());
      final userProfile = await authenticationRepository.authenticationUser(
        baseUrl,
        userName,
        password);

      await _accountRepository.setCurrentAccount(
        PersonalAccount(
          id: userName.value,
          authType: AuthenticationType.basic,
          isSelected: true,
          baseUrl: baseUrl.toString(),
          basicAuth: BasicAuth(userName, password)
        )
      );

      yield Right(AuthenticationUserSuccess(userProfile));
    } catch (e) {
      yield Left(AuthenticationUserFailure(e));
    }
  }
}