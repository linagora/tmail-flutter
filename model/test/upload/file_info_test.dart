import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';

void main() {
  group('FileInfo.readBytes', () {
    test('returns existing bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final fileInfo = FileInfo(fileName: 'file.bin', fileSize: 3, bytes: bytes);

      expect(await fileInfo.readBytes(), same(bytes));
    });

    test('collects bytes from openRead', () async {
      final fileInfo = FileInfo(
        fileName: 'file.bin',
        fileSize: 3,
        openRead: ([start, end]) => Stream<List<int>>.fromIterable([
          [1, 2],
          [3],
        ]),
      );

      expect(await fileInfo.readBytes(), [1, 2, 3]);
    });

    test('throws when neither bytes nor openRead is available', () async {
      final fileInfo = FileInfo(fileName: 'file.bin', fileSize: 3);

      await expectLater(fileInfo.readBytes(), throwsStateError);
    });
  });
}
