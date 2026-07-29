import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';

void main() {
  group('StagedDriveFile', () {
    test('FileBackedStagedFile.dispose calls the injected deleteFile', () async {
      String? deletedPath;
      final staged = FileBackedStagedFile(
        filePath: '/tmp/foo',
        deleteFile: (path) async => deletedPath = path,
        fileName: 'foo.txt',
        fileSize: 10,
      );

      await staged.dispose();

      expect(deletedPath, '/tmp/foo');
    });

    test('OpfsStagedFile.dispose calls removeEntry with the handle', () async {
      Object? removed;
      final handle = Object();
      final staged = OpfsStagedFile(
        fileHandle: handle,
        removeEntry: (h) async => removed = h,
        fileName: 'foo.txt',
        fileSize: 10,
      );

      await staged.dispose();

      expect(identical(removed, handle), isTrue);
    });

    test('BytesStagedFile.dispose is a no-op', () async {
      final staged = BytesStagedFile(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'foo.txt',
        fileSize: 3,
      );

      await staged.dispose();
    });

    test('equality compares bytes by identity, not content', () {
      final sharedBytes = Uint8List.fromList([1]);
      final a = BytesStagedFile(
          bytes: sharedBytes, fileName: 'a', fileSize: 1);
      final b = BytesStagedFile(
          bytes: sharedBytes, fileName: 'a', fileSize: 1);
      final c = BytesStagedFile(
          bytes: Uint8List.fromList([1]), fileName: 'a', fileSize: 1);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
