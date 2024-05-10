import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/uri_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';

class GetCredentialInteractor {
  final CredentialRepository credentialRepository;

  GetCredentialInteractor(this.credentialRepository);

  Future<Either<Failure, Success>> execute({
    required PersonalAccount personalAccount,
    StateChange? stateChange
  }) async {
    try {
      final baseUrl = await credentialRepository.getBaseUrl();
      final authenticationInfo = await credentialRepository.getAuthenticationInfoStored();
      if (isCredentialValid(baseUrl)) {
        return Right(GetCredentialViewState(
          baseUrl,
          UserName(authenticationInfo.username),
          Password(authenticationInfo.password),
          personalAccount,
          stateChange: stateChange));
      } else {
        return Left(GetCredentialFailure(BadCredentials()));
      }
    } catch (exception) {
      return Left(GetCredentialFailure(exception));
    }
  }

  bool isCredentialValid(Uri baseUrl) => baseUrl.isBaseUrlValid();
}