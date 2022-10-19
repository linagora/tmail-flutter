import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';

class EditIdentityInteractor {
  final IdentityRepository _identityRepository;

  EditIdentityInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      EditIdentityRequest editIdentityRequest
  ) async* {
    try {
      yield Right(EditIdentityLoading());
      final result = await _identityRepository.editIdentity(accountId, editIdentityRequest);
      yield result ? Right(EditIdentitySuccess()) : Left(EditIdentityFailure(null));
    } catch (exception) {
      yield Left(EditIdentityFailure(exception));
    }
  }
}