
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/identity_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';

class IdentityRepositoryImpl extends IdentityRepository {

  final IdentityDataSource _dataSource;

  IdentityRepositoryImpl(this._dataSource);

  @override
  Future<IdentitiesResponse> getAllIdentities(Session session, AccountId accountId, {Properties? properties}) {
    return _dataSource.getAllIdentities(session, accountId, properties: properties);
  }

  @override
  Future<Identity> createNewIdentity(Session session, AccountId accountId, CreateNewIdentityRequest identityRequest) {
    return _dataSource.createNewIdentity(session, accountId, identityRequest);
  }

  @override
  Future<bool> deleteIdentity(Session session, AccountId accountId, IdentityId identityId) {
    return _dataSource.deleteIdentity(session, accountId, identityId);
  }

  @override
  Future<bool> editIdentity(Session session, AccountId accountId, EditIdentityRequest editIdentityRequest) {
    return _dataSource.editIdentity(session, accountId, editIdentityRequest);
  }

  @override
  Future<IdentitySignature> transformHtmlSignature(IdentitySignature identitySignature) {
    return _dataSource.transformHtmlSignature(identitySignature);
  }
}