import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource/public_asset_datasource.dart';
import 'package:tmail_ui_user/features/public_asset/data/repository/public_asset_repository_impl.dart';

import 'public_asset_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PublicAssetDatasource>(),
  MockSpec<Session>(),
  MockSpec<AccountId>(),
])
void main() {
  final publicAssetDatasource = MockPublicAssetDatasource();
  final publicAssetRepository = PublicAssetRepositoryImpl(publicAssetDatasource);
  final session = MockSession();
  final accoundId = MockAccountId();
  final identityId = IdentityId(Id('123'));

  group('public asset repository impl test:', () {
    test(
      'should redirect the call to publicAssetDatasource.getPublicAssetFromIds '
      'when getPublicAssetFromIds in repository is called',
    () async {
      // arrange
      final publicAssetIds = [Id('123')];
      
      // act
      await publicAssetRepository.getPublicAssetsFromIds(
        session,
        accoundId,
        publicAssetIds: publicAssetIds
      );
      
      // assert
      verify(publicAssetDatasource.getPublicAssetFromIds(
        session,
        accoundId,
        publicAssetIds: publicAssetIds
      )).called(1);
    });

    test(
      'should redirect the call to publicAssetDatasource.createPublicAsset '
      'when createPublicAsset in repository is called',
    () async {
      // arrange
      final blobId = Id('123');
      
      // act
      await publicAssetRepository.createPublicAsset(
        session,
        accoundId,
        blobId: blobId,
        identityId: identityId
      );
      
      // assert
      verify(publicAssetDatasource.createPublicAsset(
        session,
        accoundId,
        blobId: blobId,
        identityId: identityId
      )).called(1);
    });

    test(
      'should redirect the call to publicAssetDatasource.deletePublicAssets '
      'when deletePublicAssets in repository is called',
    () async {
      // arrange
      final publicAssetIds = [Id('123')];
      
      // act
      await publicAssetRepository.deletePublicAssets(
        session,
        accoundId,
        publicAssetIds: publicAssetIds
      );
      
      // assert
      verify(publicAssetDatasource.deletePublicAssets(
        session,
        accoundId,
        publicAssetIds: publicAssetIds
      )).called(1);
    });

    test(
      'should redirect the call to publicAssetDatasource.updatePublicAssets '
      'when updatePublicAssets in repository is called',
    () async {
      // arrange
      final publicAssets = [PublicAsset(id: Id('123'))];
      
      // act
      await publicAssetRepository.updatePublicAssets(
        session,
        accoundId,
        publicAssets: publicAssets
      );
      
      // assert
      verify(publicAssetDatasource.updatePublicAssets(
        session,
        accoundId,
        publicAssets: publicAssets
      )).called(1);
    });
  });
}