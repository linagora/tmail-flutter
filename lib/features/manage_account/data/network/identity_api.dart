
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_method.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_response.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/identities/set/set_identity_method.dart';
import 'package:jmap_dart_client/jmap/identities/set/set_identity_response.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:model/extensions/list_identity_id_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_default_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_default_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class IdentityAPI {
  final HttpClient _httpClient;

  IdentityAPI(this._httpClient);

  Future<IdentitiesResponse> getAllIdentities(Session session, AccountId accountId, {Properties? properties}) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final getIdentityMethod = GetIdentityMethod(accountId);
    if (properties != null) {
      getIdentityMethod.addProperties(properties);
    }

    final jamesSortOrderIsSupported = [CapabilityIdentifier.jamesSortOrder].isSupported(session, accountId);
    final capabilitySupported = jamesSortOrderIsSupported
      ? getIdentityMethod.requiredCapabilitiesSupportSortOrder
      : getIdentityMethod.requiredCapabilities;

    final queryInvocation = requestBuilder.invocation(getIdentityMethod);

    final result = await (requestBuilder
        ..usings(capabilitySupported))
      .build()
      .execute();

    final response = result.parse<GetIdentityResponse>(
        queryInvocation.methodCallId,
        GetIdentityResponse.deserialize);

    return IdentitiesResponse(identities: response?.list, state: response?.state);
  }

  Future<Identity> createNewIdentity(Session session, AccountId accountId, CreateNewIdentityRequest identityRequest) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addCreate(identityRequest.creationId, identityRequest.newIdentity);

    final jamesSortOrderIsSupported = [CapabilityIdentifier.jamesSortOrder].isSupported(session, accountId);
    final capabilitySupported = jamesSortOrderIsSupported
      ? setIdentityMethod.requiredCapabilitiesSupportSortOrder
      : setIdentityMethod.requiredCapabilities;

    if (jamesSortOrderIsSupported &&
        identityRequest is CreateNewDefaultIdentityRequest &&
        identityRequest.oldDefaultIdentityIds != null
    ) {
      setIdentityMethod.addUpdates(
        identityRequest.oldDefaultIdentityIds!.generateMapUpdateObjectSortOrder(sortOrder: UnsignedInt(100))
      );
    }

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
        ..usings(capabilitySupported))
      .build()
      .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return setIdentityResponse!.created![identityRequest.creationId]!;
  }

  Future<bool> deleteIdentity(Session session, AccountId accountId, IdentityId identityId) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addDestroy({identityId.id});

    final jamesSortOrderIsSupported = [CapabilityIdentifier.jamesSortOrder].isSupported(session, accountId);
    final capabilitySupported = jamesSortOrderIsSupported
      ? setIdentityMethod.requiredCapabilitiesSupportSortOrder
      : setIdentityMethod.requiredCapabilities;

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
        ..usings(capabilitySupported))
      .build()
      .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return setIdentityResponse?.destroyed?.contains(identityId.id) == true;
  }

  Future<bool> editIdentity(Session session, AccountId accountId, EditIdentityRequest editIdentityRequest) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addUpdates({
        editIdentityRequest.identityId.id : PatchObject(editIdentityRequest.identityRequest.toJson())
      });

    final jamesSortOrderIsSupported = [CapabilityIdentifier.jamesSortOrder].isSupported(session, accountId);
    final capabilitySupported = jamesSortOrderIsSupported
      ? setIdentityMethod.requiredCapabilitiesSupportSortOrder
      : setIdentityMethod.requiredCapabilities;
    
    if (jamesSortOrderIsSupported &&
        editIdentityRequest is EditDefaultIdentityRequest &&
        editIdentityRequest.oldDefaultIdentityIds != null
    ) {
      setIdentityMethod.addUpdates(
        editIdentityRequest.oldDefaultIdentityIds!.generateMapUpdateObjectSortOrder(sortOrder: UnsignedInt(100))
      );
    }

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
        ..usings(capabilitySupported))
      .build()
      .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return setIdentityResponse?.updated?.containsKey(editIdentityRequest.identityId.id) == true;
  }
}