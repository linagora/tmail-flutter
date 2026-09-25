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

    test('carries an openRead factory that opens a fresh source per call', () async {
      final openRead = uploadExtra(blobBody())[UploadRequestExtra.openReadKey]
          as Stream<List<int>> Function();

      expect(await openRead().toList(), [sourceBytes]);
      expect(await openRead().toList(), [sourceBytes]);
      expect(opens, [(null, null), (null, null)]);
    });

    test('forwards the charset probe range to the source', () async {
      await blobBody().open(0, 2).drain<void>();

      expect(opens, [(0, 2)]);
    });
  });
}
