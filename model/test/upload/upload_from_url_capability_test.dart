import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/upload_from_url_capability.dart';

void main() {
  group('UploadFromUrlCapability::json', () {
    test('SHOULD parse the advertised uploadUrl template', () {
      final capability = UploadFromUrlCapability.deserialize({
        'uploadUrl': 'https://mail.example.com/upload-from-url/{accountId}',
      });

      expect(
        capability.uploadUrl.toString(),
        'https://mail.example.com/upload-from-url/%7BaccountId%7D',
      );
    });

    test('SHOULD return null uploadUrl WHEN the key is absent', () {
      final capability = UploadFromUrlCapability.deserialize({});

      expect(capability.uploadUrl, isNull);
    });

    test('SHOULD round-trip the uploadUrl back to json', () {
      final capability = UploadFromUrlCapability(
        uploadUrl: Uri.parse('https://mail.example.com/upload-from-url/alice'),
      );

      expect(capability.toJson(), {
        'uploadUrl': 'https://mail.example.com/upload-from-url/alice',
      });
    });

    test('SHOULD omit the uploadUrl from json WHEN it is null', () {
      expect(UploadFromUrlCapability().toJson(), isEmpty);
    });
  });
}
