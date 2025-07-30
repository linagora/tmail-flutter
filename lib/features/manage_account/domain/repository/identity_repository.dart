import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';

abstract class IdentityRepository {
  Future<IdentitiesResponse> getAllIdentities(Session session, AccountId accountId, {Properties? properties});

  Future<Identity> createNewIdentity(Session session, AccountId accountId, CreateNewIdentityRequest identityRequest);

  Future<bool> deleteIdentity(Session session, AccountId accountId, IdentityId identityId);

  Future<bool> editIdentity(Session session, AccountId accountId, EditIdentityRequest editIdentityRequest);

  Future<IdentitySignature> transformHtmlSignature(IdentitySignature identitySignature);
}