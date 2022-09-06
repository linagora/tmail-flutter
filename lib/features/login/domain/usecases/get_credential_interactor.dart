import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/uri_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';

class GetCredentialInteractor {
  final CredentialRepository credentialRepository;

  GetCredentialInteractor(this.credentialRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      final baseUrl = await credentialRepository.getBaseUrl();
      final authenticationInfo = await credentialRepository.getAuthenticationInfoStored();
      if (isCredentialValid(baseUrl) && authenticationInfo != null) {
        return Right(GetCredentialViewState(
            baseUrl,
            UserName(authenticationInfo.username),
            Password(authenticationInfo.password)));
      } else {
        return Left(GetCredentialFailure(BadCredentials()));
      }
    } catch (exception) {
      return Left(GetCredentialFailure(exception));
    }
  }

  bool isCredentialValid(Uri baseUrl) => baseUrl.isBaseUrlValid();
}