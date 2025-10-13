import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource/public_asset_datasource.dart';
import 'package:tmail_ui_user/features/public_asset/data/network/public_asset_api.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class RemotePublicAssetDatasourceImpl implements PublicAssetDatasource {
  const RemotePublicAssetDatasourceImpl(this._publicAssetApi, this._exceptionThrower);

  final PublicAssetApi _publicAssetApi;
  final ExceptionThrower _exceptionThrower;

  @override
  Future<PublicAsset> createPublicAsset(
    Session session,
    AccountId accountId,
    {
      required Id blobId,
      required IdentityId? identityId
    }
  ) => Future.sync(() async {
    return await _publicAssetApi.createPublicAsset(
      session,
      accountId,
      blobId: blobId,
      identityId: identityId);
      }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });

  @override
  Future<void> deletePublicAssets(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) => Future.sync(() async {
    return await _publicAssetApi.destroyPublicAssets(
      session,
      accountId,
      publicAssetIds: publicAssetIds
    );
      }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });

  @override
  Future<List<PublicAsset>> getPublicAssetFromIds(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) => Future.sync(() async {
    return await _publicAssetApi.getPublicAssets(
      session,
      accountId,
      publicAssetIds: publicAssetIds
    );
      }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });

  @override
  Future<void> updatePublicAssets(
    Session session,
    AccountId accountId,
    {required List<PublicAsset> publicAssets}
  ) => Future.sync(() async {
    return await _publicAssetApi.updatePublicAssets(
      session,
      accountId,
      publicAssets: publicAssets
    );
      }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });

  @override
  Future<void> partialUpdatePublicAssets(
    Session session,
    AccountId accountId,
    {required Map<Id, UpdatingIdentityIds> mapPublicAssetIdToUpdatingIdentityIds}
  ) => Future.sync(() async {
    return await _publicAssetApi.partialUpdatePublicAssets(
      session,
      accountId,
      mapPublicAssetIdToUpdatingIdentityIds: mapPublicAssetIdToUpdatingIdentityIds
    );
      }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
}