import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_default_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';

class EditDefaultIdentityInteractor {
  final IdentityRepository _identityRepository;
  final IdentityUtils _identityUtils;

  EditDefaultIdentityInteractor(
    this._identityRepository,
    this._identityUtils
  );

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EditIdentityRequest editIdentityRequest
  ) async* {
    try {
      yield Right(EditDefaultIdentityLoading());

      final defaultIdentities = await _getDefaultIdentities(session, accountId);
      _removeEditIdentityFromDefaultIdentities(defaultIdentities, editIdentityRequest.identityId);

      final editDefaultRequest = EditDefaultIdentityRequest(
        identityId: editIdentityRequest.identityId, 
        identityRequest: editIdentityRequest.identityRequest,
        isDefaultIdentity: editIdentityRequest.isDefaultIdentity,
        publicAssetsInIdentityArguments: editIdentityRequest.publicAssetsInIdentityArguments,
        oldDefaultIdentityIds: defaultIdentities
            ?.map((identity) => identity.id!)
            .toList());

      final result = await _identityRepository.editIdentity(session, accountId, editDefaultRequest);
      yield result
        ? Right(EditDefaultIdentitySuccess(
            editDefaultRequest.identityId,
            publicAssetsInIdentityArguments: editDefaultRequest.publicAssetsInIdentityArguments))
        : Left(EditDefaultIdentityFailure(null));
    } catch (exception) {
      yield Left(EditDefaultIdentityFailure(exception));
    }
  }

  Future<List<Identity>?> _getDefaultIdentities(Session session, AccountId accountId) async {
    final listIdentities = await _identityRepository
      .getAllIdentities(
        session,
        accountId,
        properties: Properties({'sortOrder'})
      );
    return _identityUtils
        .getSmallestOrderedIdentity(listIdentities.identities)
        ?.toList();
  }

  void _removeEditIdentityFromDefaultIdentities(
    List<Identity>? defaultIdentities, 
    IdentityId editIdentityId
  ) {
    defaultIdentities?.removeWhere((identity) => identity.id == editIdentityId);
  }
}