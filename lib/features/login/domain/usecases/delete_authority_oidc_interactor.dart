import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/delete_authority_oidc_state.dart';

class DeleteAuthorityOidcInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  DeleteAuthorityOidcInteractor(this._authenticationOIDCRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      await _authenticationOIDCRepository.deleteAuthorityOidc();
      return Right(DeleteAuthorityOidcSuccess());
    } catch (exception) {
      return Left(DeleteAuthorityOidcFailure(exception));
    }
  }
}