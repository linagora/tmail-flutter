import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_default_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';

class CreateNewDefaultIdentityInteractor {
  final IdentityRepository _identityRepository;
  final IdentityUtils _identityUtils;

  CreateNewDefaultIdentityInteractor(
    this._identityRepository,
    this._identityUtils);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    CreateNewIdentityRequest identityRequest
  ) async* {
    try {
      yield Right(CreateNewDefaultIdentityLoading());
      final listDefaultIdentities = await _getDefaultIdentities(session, accountId);

      final defaultRequest = _createNewIdentityDefault(identityRequest, listDefaultIdentities);
      
      final newIdentity = await _identityRepository.createNewIdentity(session, accountId, defaultRequest);
      yield Right(CreateNewDefaultIdentitySuccess(
        newIdentity,
        publicAssetsInIdentityArguments: identityRequest.publicAssetsInIdentityArguments));
    } catch (exception) {
      yield Left(CreateNewDefaultIdentityFailure(exception));
    }
  }

  Future<List<Identity>?> _getDefaultIdentities(Session session, AccountId accountId) async {
    final listIdentities = await _identityRepository
      .getAllIdentities(
        session,
        accountId,
        properties: Properties({'sortOrder', 'mayDelete'})
      );
    listIdentities.identities?.removeWhere(_isIdentityUnDeletable);
    return _identityUtils.getSmallestOrderedIdentity(listIdentities.identities);
  }

  bool _isIdentityUnDeletable(Identity identity) {
    return identity.mayDelete != true;
  }

  CreateNewDefaultIdentityRequest _createNewIdentityDefault(
    CreateNewIdentityRequest identityRequest,
    List<Identity>? listDefaultIdentities,
  ) {
    return CreateNewDefaultIdentityRequest(
      identityRequest.creationId, 
      identityRequest.newIdentity,
      oldDefaultIdentityIds: listDefaultIdentities
          ?.map((identity) => identity.id!)
          .toList());
  }
}