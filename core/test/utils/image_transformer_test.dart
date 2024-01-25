import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const imageTransformer = ImageTransformer();

  group('findImageUrlFromStyleTag test', () {
    test('Test findImageUrlFromStyleTag with valid input', () {
      const style = 'background-image: url(\'example.com/image.jpg\');';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result!.value1, 'background-image: url(\'example.com/image.jpg\')');
      expect(result.value2, 'example.com/image.jpg');
    });

    test('Test findImageUrlFromStyleTag with valid input and no quotation marks', () {
      const style = 'background-image: url(example.com/image.jpg);';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result!.value1, 'background-image: url(example.com/image.jpg)');
      expect(result.value2, 'example.com/image.jpg');
    });

    test('Test findImageUrlFromStyleTag with empty input', () {
      const style = '';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result, null);
    });

    test('Test findImageUrlFromStyleTag with invalid input', () {
      const style = 'background-image: invalid-url(\'example.com/image.jpg\');';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result, null);
    });
  });
}