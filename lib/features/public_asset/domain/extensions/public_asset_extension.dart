import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';

extension PublicAssetExtension on PublicAsset {
  PublicAsset withRemovedIdentityId(IdentityId toBeRemovedIdentityId) {
    return PublicAsset(
      id: id,
      publicURI: publicURI,
      size: size,
      contentType: contentType,
      blobId: blobId,
      identityIds: identityIds?..remove(toBeRemovedIdentityId),
    );
  }

  PublicAsset withAddedIdentityId(IdentityId toBeAddedIdentityId) {
    return PublicAsset(
      id: id,
      publicURI: publicURI,
      size: size,
      contentType: contentType,
      blobId: blobId,
      identityIds: identityIds?..addAll({toBeAddedIdentityId: true}),
    );
  }
}