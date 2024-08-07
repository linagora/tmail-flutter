import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource/public_asset_datasource.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';

class PublicAssetRepositoryImpl implements PublicAssetRepository {
  const PublicAssetRepositoryImpl(this._publicAssetDatasource);

  final PublicAssetDatasource _publicAssetDatasource;

  @override
  Future<List<PublicAsset>> getPublicAssetsFromIds(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) => _publicAssetDatasource.getPublicAssetFromIds(
    session,
    accountId,
    publicAssetIds: publicAssetIds);

  @override
  Future<void> deletePublicAssets(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  ) => _publicAssetDatasource.deletePublicAssets(
    session,
    accountId,
    publicAssetIds: publicAssetIds);

  @override
  Future<PublicAsset> createPublicAsset(
    Session session,
    AccountId accountId,
    {
      required Id blobId,
      required IdentityId? identityId
    }
  ) => _publicAssetDatasource.createPublicAsset(
    session,
    accountId,
    blobId: blobId,
    identityId: identityId);

  @override
  Future<void> updatePublicAssets(
    Session session,
    AccountId accountId,
    {required List<PublicAsset> publicAssets}
  ) => _publicAssetDatasource.updatePublicAssets(
    session,
    accountId,
    publicAssets: publicAssets);
}