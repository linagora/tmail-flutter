import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource_impl/remote_public_asset_datasource_impl.dart';
import 'package:tmail_ui_user/features/public_asset/data/network/public_asset_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

import 'remote_public_asset_datasource_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PublicAssetApi>(),
  MockSpec<ExceptionThrower>(),
  MockSpec<Session>(),
  MockSpec<AccountId>(),
])
void main() {
  final publicAssetApi = MockPublicAssetApi();
  final exceptionThrower = MockExceptionThrower();
  final publicAssetDatasource = RemotePublicAssetDatasourceImpl(
    publicAssetApi,
    exceptionThrower);
  final session = MockSession();
  final accoundId = MockAccountId();
  final identityId = IdentityId(Id('123'));

  group('remote public asset datasource impl test:', () {
    test(
      'should return expected public assets '
      'when publicAssetApi.getPublicAssets is called '
      'and publicAssetApi.getPublicAssets return public assets',
    () async {
      // arrange
      final publicAssetId = Id('123');
      final publicAsset = PublicAsset(id: publicAssetId);
      when(
        publicAssetApi.getPublicAssets(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds')),
      ).thenAnswer((_) => Future.value([publicAsset]));

      // act
      final result = await publicAssetDatasource.getPublicAssetFromIds(
        session,
        accoundId,
        publicAssetIds: [publicAssetId],
      );
      
      // assert
      verify(publicAssetApi.getPublicAssets(
        session,
        accoundId,
        publicAssetIds: [publicAssetId],
      )).called(1);
      expect(result, equals([publicAsset]));
    });

    test(
      'should throw expected exception '
      'when publicAssetApi.getPublicAssets is called '
      'and publicAssetApi.getPublicAssets throw exception',
    () async {
      // arrange
      when(
        publicAssetApi.getPublicAssets(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds')),
      ).thenThrow(Exception());
      when(exceptionThrower.throwException(any, any)).thenThrow(Exception());
      
      // assert
      expect(() => publicAssetDatasource.getPublicAssetFromIds(
        session,
        accoundId,
        publicAssetIds: [Id('123')],
      ), throwsException);
    });

    test(
      'should return expected public asset '
      'when publicAssetApi.createPublicAsset is called '
      'and publicAssetApi.createPublicAsset return public asset',
    () async {
      // arrange
      final blobId = Id('123');
      final publicAsset = PublicAsset();
      when(
        publicAssetApi.createPublicAsset(
          any,
          any,
          blobId: anyNamed('blobId'),
          identityId: anyNamed('identityId')),
      ).thenAnswer((_) => Future.value(publicAsset));
      
      // act
      final result = await publicAssetDatasource.createPublicAsset(
        session,
        accoundId,
        blobId: blobId,
        identityId: identityId,
      );
      
      // assert
      verify(publicAssetApi.createPublicAsset(
        session,
        accoundId,
        blobId: blobId,
        identityId: identityId,
      )).called(1);
      expect(result, equals(publicAsset));  
    });

    test(
      'should throw expected exception '
      'when publicAssetApi.createPublicAsset is called '
      'and publicAssetApi.createPublicAsset throw exception',
    () async {
      // arrange
      when(
        publicAssetApi.createPublicAsset(
          any,
          any,
          blobId: anyNamed('blobId'),
          identityId: anyNamed('identityId')),
      ).thenThrow(Exception());
      when(exceptionThrower.throwException(any, any)).thenThrow(Exception());
      
      // assert
      expect(() => publicAssetDatasource.createPublicAsset(
        session,
        accoundId,
        blobId: Id('123'),
        identityId: identityId,
      ), throwsException);
    });

    test(
      'should redirect the call to publicAssetApi.destroyPublicAssets '
      'when deletePublicAssets is called',
    () async {
      // arrange
      final publicAssetIds = [Id('123')];
      
      // act
      await publicAssetDatasource.deletePublicAssets(
        session,
        accoundId,
        publicAssetIds: publicAssetIds,
      );
      
      // assert
      verify(publicAssetApi.destroyPublicAssets(
        session,
        accoundId,
        publicAssetIds: publicAssetIds,
      )).called(1);
    });

    test(
      'should throw expected exception '
      'when publicAssetApi.destroyPublicAssets is called '
      'and publicAssetApi.destroyPublicAssets throw exception',
    () async {
      // arrange
      when(
        publicAssetApi.destroyPublicAssets(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds')),
      ).thenThrow(Exception());
      when(exceptionThrower.throwException(any, any)).thenThrow(Exception());
      
      // assert
      expect(() => publicAssetDatasource.deletePublicAssets(
        session,
        accoundId,
        publicAssetIds: [Id('123')],
      ), throwsException);
    });

    test(
      'should redirect the call to publicAssetApi.updatePublicAssets '
      'when updatePublicAssets is called',
    () async {
      // arrange
      final publicAssets = [PublicAsset()];
      
      // act
      await publicAssetDatasource.updatePublicAssets(
        session,
        accoundId,
        publicAssets: publicAssets,
      );
      
      // assert
      verify(publicAssetApi.updatePublicAssets(
        session,
        accoundId,
        publicAssets: publicAssets,
      )).called(1);
    });

    test(
      'should throw expected exception '
      'when publicAssetApi.updatePublicAssets is called '
      'and publicAssetApi.updatePublicAssets throw exception',
    () async {
      // arrange
      when(
        publicAssetApi.updatePublicAssets(
          any,
          any,
          publicAssets: anyNamed('publicAssets')),
      ).thenThrow(Exception());
      when(exceptionThrower.throwException(any, any)).thenThrow(Exception());
      
      // assert
      expect(() => publicAssetDatasource.updatePublicAssets(
        session,
        accoundId,
        publicAssets: [PublicAsset()],
      ), throwsException);
    });
  });
}