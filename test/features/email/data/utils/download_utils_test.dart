import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/utils/download_utils.dart';
import 'package:uuid/uuid.dart';

import 'download_utils_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Uuid>(),
])
void main() {
  late MockUuid uuid;
  late DownloadUtils downloadUtils;

  final accountId = AccountId(Id('abc123'));
  const baseDownloadUrl = 'https://example.com/download/{accountId}/{blobId}?type={type}&name={name}';
  final blobId = Id('xyz123');

  setUp(() {
    uuid = MockUuid();
    downloadUtils = DownloadUtils(uuid);
  });

  group('getDownloadUrl method test', () {
    test('should be url decoded correctly in case of fileName & mimeType are not null', () async {
      const expectedDownloadUrl = 'https://example.com/download/abc123/xyz123?type=&name=';

      final downloadUrl = downloadUtils.getDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId);

      expect(downloadUrl, expectedDownloadUrl);
    });

    test('should be url decoded correctly in case of fileName & mimeType are null', () async {
      const expectedDownloadUrl = 'https://example.com/download/abc123/xyz123?type=application/octet-stream&name=hello.eml';

      final downloadUrl = downloadUtils.getDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          fileName: 'hello.eml',
          mimeType: 'application/octet-stream');

      expect(downloadUrl, expectedDownloadUrl);
    });
  });

  group('getEMLDownloadUrl method test', () {
    test('should be url decoded correctly in case of subject is not empty', () async {
      const expectedDownloadUrl = 'https://example.com/download/abc123/xyz123?type=application/octet-stream&name=hello.eml';

      final downloadUrl = downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: 'hello');

      expect(downloadUrl, expectedDownloadUrl);
    });

    test('should be url decoded correctly in case of subject is empty', () async {
      const nameFixture = '12345678';
      const expectedDownloadUrl = 'https://example.com/download/abc123/xyz123?type=application/octet-stream&name=$nameFixture.eml';

      when(uuid.v1()).thenAnswer((_) => nameFixture);

      final downloadUrl = downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: '');

      expect(downloadUrl, expectedDownloadUrl);
    });
  });
}
