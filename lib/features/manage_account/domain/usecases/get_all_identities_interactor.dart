import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class GetAllIdentitiesInteractor {
  final IdentityRepository _identityRepository;
  final IdentityUtils _identityUtils;

  GetAllIdentitiesInteractor(this._identityRepository, this._identityUtils);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(GetAllIdentitiesLoading());
      final identitiesResponse = await _identityRepository.getAllIdentities(session, accountId, properties: properties);
      final sortOrderIsSupported = [CapabilityIdentifier.jamesSortOrder].isSupported(session, accountId);
      if (sortOrderIsSupported && identitiesResponse.identities != null) {
        _identityUtils.sortListIdentities(identitiesResponse.identities!);
      }
      yield Right(GetAllIdentitiesSuccess(
        identitiesResponse.identities
          ?.where((identity) => identity.name?.trim().isNotEmpty == true)
          .toList(),
        identitiesResponse.state));
    } catch (exception) {
      yield Left(GetAllIdentitiesFailure(exception));
    }
  }
}