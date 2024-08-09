import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_identity_state.dart';

class CreateNewIdentityInteractor {
  final IdentityRepository _identityRepository;

  CreateNewIdentityInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    CreateNewIdentityRequest identityRequest
  ) async* {
    try {
      yield Right(CreateNewIdentityLoading());
      final newIdentity = await _identityRepository.createNewIdentity(session, accountId, identityRequest);
      yield Right(CreateNewIdentitySuccess(
        newIdentity,
        publicAssetsInIdentityArguments: identityRequest.publicAssetsInIdentityArguments));
    } catch (exception) {
      yield Left(CreateNewIdentityFailure(exception));
    }
  }
}