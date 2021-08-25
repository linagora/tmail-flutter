import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/delete_credential_state.dart';

class DeleteCredentialInteractor {
  final CredentialRepository credentialRepository;

  DeleteCredentialInteractor(this.credentialRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      await Future.wait([
        credentialRepository.removeBaseUrl(),
        credentialRepository.removeUserName(),
        credentialRepository.removePassword(),
        credentialRepository.removeUserProfile(),
      ]);
      return Right(DeleteCredentialSuccess());
    } catch (exception) {
      return Left(DeleteCredentialFailure(exception));
    }
  }
}