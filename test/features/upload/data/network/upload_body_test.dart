import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_body.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';

void main() {
  group('HandleUploadBody', () {
    const sourceUrl = 'blob:http://localhost/attachment';
    const sourceBytes = <int>[1, 2, 3];
    late List<(int?, int?)> opens;

    setUp(() => opens = <(int?, int?)>[]);

    UploadBody blobBody() => UploadBody.of(FileBlobInfo(
      fileName: 'a.pdf',
      fileSize: sourceBytes.length,
      sourceUrl: sourceUrl,
      openRead: ([start, end]) {
        opens.add((start, end));
        return Stream<List<int>>.value(sourceBytes);
      },
    ));

    Map<String, dynamic> uploadExtra(UploadBody body) =>
        body.dioExtra[UploadRequestExtra.uploadAttachmentKey] as Map<String, dynamic>;

    test('is the body a FileBlobInfo maps to', () {
      expect(blobBody(), isA<HandleUploadBody>());
    });

    test('has no request data so the blob adapter sends the source itself', () {
      expect(blobBody().requestData, isNull);
      expect(opens, isEmpty);
    });

    test('carries the blob sourceUrl in its extras', () {
      expect(uploadExtra(blobBody())[UploadRequestExtra.sourceUrlKey], sourceUrl);
    });

    test('carries no openRead factory since the blob adapter re-resolves sourceUrl', () {
      expect(uploadExtra(blobBody()).containsKey(UploadRequestExtra.openReadKey), isFalse);
      expect(opens, isEmpty);
    });

    test('forwards the charset probe range to the source', () async {
      await blobBody().open(0, 2).drain<void>();

      expect(opens, [(0, 2)]);
    });
  });

  group('StreamUploadBody', () {
    const sourceBytes = <int>[1, 2, 3];

    UploadBody bytesBody() => UploadBody.of(FileBytesInfo(
      bytes: Uint8List.fromList(sourceBytes),
      fileName: 'a.pdf',
    ));

    test('opens a fresh stream on each requestData read so a retry resends the whole file', () async {
      final body = bytesBody();

      final first = await (body.requestData as Stream<List<int>>).toList();
      final second = await (body.requestData as Stream<List<int>>).toList();

      expect(first, [sourceBytes]);
      expect(second, [sourceBytes]);
    });
  });
}
