import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';

class DeleteIdentityInteractor {
  final IdentityRepository _identityRepository;

  DeleteIdentityInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, IdentityId identityId) async* {
    try {
      yield Right(DeleteIdentityLoading());
      final result = await _identityRepository.deleteIdentity(accountId, identityId);
      yield result ? Right(DeleteIdentitySuccess()) : Left(DeleteIdentityFailure(null));
    } catch (exception) {
      yield Left(DeleteIdentityFailure(exception));
    }
  }
}