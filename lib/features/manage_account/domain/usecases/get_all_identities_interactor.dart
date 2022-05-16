import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';

class GetAllIdentitiesInteractor {
  final ManageAccountRepository manageAccountRepository;

  GetAllIdentitiesInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final identitiesResponse = await manageAccountRepository.getAllIdentities(accountId, properties: properties);
      yield Right(GetAllIdentitiesSuccess(identitiesResponse.identities, identitiesResponse.state));
    } catch (exception) {
      yield Left(GetAllIdentitiesFailure(exception));
    }
  }
}