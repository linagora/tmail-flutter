import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';

typedef UpdatingIdentityIds = Map<IdentityId, bool?>;

abstract class PublicAssetRepository {
  Future<List<PublicAsset>> getPublicAssetsFromIds(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  );

  Future<PublicAsset> createPublicAsset(
    Session session,
    AccountId accountId,
    {
      required Id blobId,
      required IdentityId? identityId
    }
  );

  Future<void> deletePublicAssets(
    Session session,
    AccountId accountId,
    {required List<Id> publicAssetIds}
  );

  Future<void> updatePublicAssets(
    Session session,
    AccountId accountId,
    {required List<PublicAsset> publicAssets}
  );

  Future<void> partialUpdatePublicAssets(
    Session session,
    AccountId accountId,
    {required Map<Id, UpdatingIdentityIds> mapPublicAssetIdToUpdatingIdentityIds}
  );
}