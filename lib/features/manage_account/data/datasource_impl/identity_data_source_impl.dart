import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/identity_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class IdentityDataSourceImpl extends IdentityDataSource {

  final IdentityAPI _identityAPI;
  final ExceptionThrower _exceptionThrower;

  IdentityDataSourceImpl(this._identityAPI, this._exceptionThrower);

  @override
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId,
      {Properties? properties}) {
    return Future.sync(() async {
      return await _identityAPI.getAllIdentities(accountId, properties: properties);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest) {
    return Future.sync(() async {
      return await _identityAPI.createNewIdentity(accountId, identityRequest);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId) {
    return Future.sync(() async {
      return await _identityAPI.deleteIdentity(accountId, identityId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest) {
    return Future.sync(() async {
      return await _identityAPI.editIdentity(accountId, editIdentityRequest);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}