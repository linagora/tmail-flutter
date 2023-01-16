import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';

class GetAllIdentitiesInteractor {
  final IdentityRepository _identityRepository;
  final IdentityUtils _identityUtils;

  GetAllIdentitiesInteractor(this._identityRepository, this._identityUtils);

  Stream<Either<Failure, Success>> execute(AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(GetAllIdentitiesLoading());
      final identitiesResponse = await _identityRepository.getAllIdentities(accountId, properties: properties);
      if (identitiesResponse.identities != null) {
        _identityUtils.sortListIdentities(identitiesResponse.identities!);
      }
      yield Right(GetAllIdentitiesSuccess(identitiesResponse.identities, identitiesResponse.state));
    } catch (exception) {
      yield Left(GetAllIdentitiesFailure(exception));
    }
  }
}