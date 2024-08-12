import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/public_asset/domain/extensions/string_to_public_asset_extension.dart';

void main() {
  group('string to public asset extension test:', () {
    test(
      'should convert string to public assets '
      'when image tags have public-asset-id attribute',
    () {
      // arrange
      const publicAssetIdValue1 = 'public-asset-1';
      const publicAssetIdValue2 = 'public-asset-2';
      const htmlString = '<img src="public-asset-1" public-asset-id="$publicAssetIdValue1"/>'
        '<img src="public-asset-2" public-asset-id="$publicAssetIdValue2"/>';

      // act
      final publicAssetIds = htmlString.publicAssetIdsFromHtmlContent;
      
      // assert
      expect(publicAssetIds, equals([Id(publicAssetIdValue1), Id(publicAssetIdValue2)]));
    });

    test(
      'should convert string to nothing '
      'when image tags do not have public-asset-id attribute',
    () {
      // arrange
      const htmlString = '<img src="public-asset-1"/><img src="public-asset-2"/>';

      // act
      final publicAssetIds = htmlString.publicAssetIdsFromHtmlContent;
      
      // assert
      expect(publicAssetIds, isEmpty);
    });

    test(
      'should only convert string to public assets '
      'when image tags have public-asset-id attribute',
    () {
      // arrange
      const publicAssetIdValue1 = 'public-asset-1';
      const htmlString = '<img src="public-asset-1" public-asset-id="$publicAssetIdValue1"/>'
        '<img src="public-asset-2"/>';

      // act
      final publicAssetIds = htmlString.publicAssetIdsFromHtmlContent;
      
      // assert
      expect(publicAssetIds, equals([Id(publicAssetIdValue1)]));
    });

    group('should convert string to public assets in various edge cases:', () {
      test(
        'when there are two "public-asset-id" attributes in the same image tag',
      () {
        // arrange
        const publicAssetIdValue1 = 'public-asset-1';
        const publicAssetIdValue2 = 'public-asset-2';
        const htmlString = '<img src="public-asset-1" '
          'public-asset-id="$publicAssetIdValue1" '
          'public-asset-id="$publicAssetIdValue2"/>';
        
        // act
        final publicAssetIds = htmlString.publicAssetIdsFromHtmlContent;
        
        // assert
        expect(publicAssetIds, equals([Id(publicAssetIdValue1)]));
      });

      test(
        'only with the "public-asset-id" attribute name',
      () {
        // arrange
        const publicAssetIdValue1 = 'public-asset-1';
        const publicAssetIdValue2 = 'public-asset-2';
        const htmlString = '<img src="public-asset-1" '
          'public-at-id="$publicAssetIdValue1" '
          'public-asset-id="$publicAssetIdValue2"/>';
        
        // act
        final publicAssetIds = htmlString.publicAssetIdsFromHtmlContent;
        
        // assert
        expect(publicAssetIds, equals([Id(publicAssetIdValue2)]));
      });
    });

    test(
      'should throw invalid argument exception '
      'when the public asset id contains invalid characters',
    () {
      // arrange
      const publicAssetIdValue1 = r'#$52323';
      const htmlString = '<img src="public-asset-1" public-asset-id="$publicAssetIdValue1"/>';
      
      // assert
      expect(
        () => htmlString.publicAssetIdsFromHtmlContent,
        throwsA(isA<ArgumentError>())
      );
    });
  });
}