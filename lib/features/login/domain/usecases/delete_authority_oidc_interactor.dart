import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/delete_authority_oidc_state.dart';

class DeleteAuthorityOidcInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final CredentialRepository _credentialRepository;

  DeleteAuthorityOidcInteractor(this._authenticationOIDCRepository, this._credentialRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      await Future.wait([
        _credentialRepository.removeBaseUrl(),
        _authenticationOIDCRepository.deleteOidcConfiguration(),
        _authenticationOIDCRepository.deleteTokenOIDC(),
      ]);
      return Right(DeleteAuthorityOidcSuccess());
    } catch (exception) {
      return Left(DeleteAuthorityOidcFailure(exception));
    }
  }
}