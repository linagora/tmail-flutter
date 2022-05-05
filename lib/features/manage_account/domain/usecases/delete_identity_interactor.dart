import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';

class DeleteIdentityInteractor {
  final ManageAccountRepository manageAccountRepository;

  DeleteIdentityInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, IdentityId identityId) async* {
    try {
      final result = await manageAccountRepository.deleteIdentity(accountId, identityId);
      yield result ? Right(DeleteIdentitySuccess()) : Left(DeleteIdentityFailure(null));
    } catch (exception) {
      yield Left(DeleteIdentityFailure(exception));
    }
  }
}