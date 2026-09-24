import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';

void main() {
  group('FileInfo.readBytes', () {
    test('returns the bytes of a FileBytesInfo as is', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final fileInfo = FileBytesInfo(bytes: bytes, fileName: 'file.bin');

      expect(await fileInfo.readBytes(), same(bytes));
    });

    test('collects the stream of a FileBlobInfo', () async {
      final fileInfo = FileBlobInfo(
        fileName: 'file.bin',
        fileSize: 3,
        sourceUrl: 'blob:x',
        openRead: ([start, end]) => Stream<List<int>>.fromIterable([
          [1, 2],
          [3],
        ]),
      );

      expect(await fileInfo.readBytes(), [1, 2, 3]);
    });

    test('throws for a FilePlaceholderInfo', () async {
      const fileInfo = FilePlaceholderInfo(fileName: 'file.bin', fileSize: 3);

      await expectLater(fileInfo.readBytes(), throwsStateError);
    });

    test('FileBytesInfo.openRead honours a byte range', () async {
      final fileInfo = FileBytesInfo(bytes: Uint8List.fromList([1, 2, 3, 4]));

      expect(await fileInfo.openRead(1, 3).toList(), [
        [2, 3],
      ]);
    });
  });
}
