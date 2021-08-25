import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';

class AuthenticationInteractor {
  final AuthenticationRepository authenticationRepository;
  final CredentialRepository credentialRepository;

  AuthenticationInteractor(this.authenticationRepository, this.credentialRepository);

  Future<Either<Failure, Success>> execute(Uri baseUrl, UserName userName, Password password) async {
    try {
      final user = await authenticationRepository.authenticationUser(baseUrl, userName, password);
      await Future.wait([
        credentialRepository.saveBaseUrl(baseUrl),
        credentialRepository.saveUserName(userName),
        credentialRepository.savePassword(password),
        credentialRepository.saveUserProfile(user),
      ]);
      return Right(AuthenticationUserViewState(user));
    } catch (e) {
      return Left(AuthenticationUserFailure(e));
    }
  }
}