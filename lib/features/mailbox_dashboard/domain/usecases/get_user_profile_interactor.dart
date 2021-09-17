import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';

class GetUserProfileInteractor {
  final CredentialRepository credentialRepository;

  GetUserProfileInteractor(this.credentialRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final userProfile = await credentialRepository.getUserProfile();
      yield Right(GetUserProfileSuccess(userProfile));
    } catch (exception) {
      yield Left(GetUserProfileFailure(exception));
    }
  }
}