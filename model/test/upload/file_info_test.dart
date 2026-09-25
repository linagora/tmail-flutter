import 'dart:async';
import 'dart:io';
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

  group('FileBytesInfo.openRead matches File.openRead', () {
    final sourceBytes = Uint8List.fromList([1, 2, 3, 4]);
    late File file;

    setUpAll(() async {
      final directory = await Directory.systemTemp.createTemp('file-bytes-info-');
      file = File('${directory.path}/source.bin');
      await file.writeAsBytes(sourceBytes);
      addTearDown(() => directory.delete(recursive: true));
    });

    // Chunks on success, the error type on failure — compared across both sources.
    Future<Object> outcome(Stream<List<int>> stream) async {
      try {
        return await stream.toList();
      } catch (error) {
        return error.runtimeType;
      }
    }

    const ranges = <(int?, int?)>[
      (null, null), (1, 3), (0, 4), (2, null), (null, 2), (1, 10),
      (4, null), (6, null), (6, 8), (2, 2), (-1, null), (3, 1), (6, 2),
    ];

    for (final (start, end) in ranges) {
      test('for start=$start end=$end', () async {
        final fileInfo = FileBytesInfo(bytes: sourceBytes);

        expect(
          await outcome(fileInfo.openRead(start, end)),
          await outcome(file.openRead(start, end)),
        );
      });
    }

    test('reports a bad range as a stream error, not a synchronous throw', () {
      final fileInfo = FileBytesInfo(bytes: sourceBytes);

      expect(() => fileInfo.openRead(-1), returnsNormally);
      expect(() => fileInfo.openRead(3, 1), returnsNormally);
      expect(() => fileInfo.openRead(6), returnsNormally);
    });
  });
}
