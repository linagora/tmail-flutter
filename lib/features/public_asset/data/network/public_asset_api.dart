import 'package:jmap_dart_client/http/converter/identities/public_asset_identities_converter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/get/get_public_asset_method.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/get/get_public_asset_response.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/set/set_public_asset_method.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/set/set_public_asset_response.dart';
import 'package:tmail_ui_user/features/public_asset/domain/exceptions/public_asset_exceptions.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';
import 'package:uuid/uuid.dart';

class PublicAssetApi {
  const PublicAssetApi(this._httpClient, this._uuid);

  final HttpClient _httpClient;
  final Uuid _uuid;

  MapEntry<Id, PatchObject> _toPatchObjectMapEntry(PublicAsset publicAsset) {
    final patchObject = PatchObject({
      PatchObject.identityIdsProperty: const PublicAssetIdentitiesConverter()
        .toJson(publicAsset.identityIds!),
    });

    return MapEntry(publicAsset.id!, patchObject);
  }

  MapEntry<PublicAssetId, PatchObject> _toPartialPatchObjectMapEntry(
    PublicAssetId publicAssetId,
    UpdatingIdentityIds updatingIdentityIds,
  ) {
    assert(
      updatingIdentityIds.values.every((value) => value != false),
      'All updating identity id values must be true or null'
    );
    final patchObject = PatchObject(updatingIdentityIds.map(
      (key, value) => MapEntry('${PatchObject.identityIdsProperty}/${key.id.value}', value)));

    return MapEntry(publicAssetId, patchObject);
  }

  Future<List<PublicAsset>> getPublicAssets(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = GetPublicAssetMethod(accountId);
    method.addIds(publicAssetIds.toSet());
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
      .build()
      .execute();
    final publicAssets = response.parse<GetPublicAssetResponse>(
        invocation.methodCallId,
        GetPublicAssetResponse.deserialize
    )?.list ?? [];

    return publicAssets;
  }

  Future<PublicAsset> createPublicAsset(
    Session session,
    AccountId accountId,
    {
      required Id blobId,
      required IdentityId? identityId
    }
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = SetPublicAssetMethod(accountId);
    final generateCreateId = Id(_uuid.v1());
    method.addCreate(
      generateCreateId,
      PublicAsset(
        blobId: blobId,
        identityIds: identityId != null ? {identityId: true} : {}
      )
    );
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
      .build()
      .execute();
    final publicAsset = response.parse<SetPublicAssetResponse>(
        invocation.methodCallId,
        SetPublicAssetResponse.deserialize
    )?.created?[generateCreateId];

    if (publicAsset == null) {
      throw const CannotCreatePublicAssetException();
    }

    return publicAsset;
  }

  Future<void> destroyPublicAssets(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = SetPublicAssetMethod(accountId);
    method.addDestroy(publicAssetIds.toSet());
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
      .build()
      .execute();

    final notDestroyedPublicAssetIds = response.parse<SetPublicAssetResponse>(
        invocation.methodCallId,
        SetPublicAssetResponse.deserialize
    )?.notDestroyed;

    if (notDestroyedPublicAssetIds?.isNotEmpty == true) {
      throw const CannotDestroyPublicAssetException();
    }
  }

  Future<void> updatePublicAssets(
    Session session,
    AccountId accountId,
    {required List<PublicAsset> publicAssets}
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = SetPublicAssetMethod(accountId);
    method.addUpdates(
      Map.fromEntries(
        publicAssets
          .where((publicAsset) => publicAsset.id != null && publicAsset.identityIds != null)
          .map(_toPatchObjectMapEntry)
      )
    );
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
      .build()
      .execute();

    final notUpdatedPublicAssetIds = response.parse<SetPublicAssetResponse>(
        invocation.methodCallId,
        SetPublicAssetResponse.deserialize
    )?.notUpdated;

    if (notUpdatedPublicAssetIds?.isNotEmpty == true) {
      throw const CannotUpdatePublicAssetException();
    }
  }

  Future<void> partialUpdatePublicAssets(
    Session session,
    AccountId accountId,
    {required Map<PublicAssetId, UpdatingIdentityIds> mapPublicAssetIdToUpdatingIdentityIds}
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = SetPublicAssetMethod(accountId);
    method.addUpdates(
      mapPublicAssetIdToUpdatingIdentityIds.map(_toPartialPatchObjectMapEntry)
    );
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
      .build()
      .execute();

    final notUpdatedPublicAssetIds = response.parse<SetPublicAssetResponse>(
        invocation.methodCallId,
        SetPublicAssetResponse.deserialize
    )?.notUpdated;

    if (notUpdatedPublicAssetIds?.isNotEmpty == true) {
      throw const CannotUpdatePublicAssetException();
    }
  }
}