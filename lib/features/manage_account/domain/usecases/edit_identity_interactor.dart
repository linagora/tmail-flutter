import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';

class EditIdentityInteractor {
  final IdentityRepository _identityRepository;

  EditIdentityInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EditIdentityRequest editIdentityRequest
  ) async* {
    try {
      yield Right(EditIdentityLoading());
      final result = await _identityRepository.editIdentity(session, accountId, editIdentityRequest);
      yield result
        ? Right(EditIdentitySuccess(
          editIdentityRequest.identityId,
          publicAssetsInIdentityArguments: editIdentityRequest.publicAssetsInIdentityArguments))
        : Left(EditIdentityFailure(null));
    } catch (exception) {
      yield Left(EditIdentityFailure(exception));
    }
  }
}