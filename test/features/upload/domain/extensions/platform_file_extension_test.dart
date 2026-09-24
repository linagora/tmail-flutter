import 'dart:typed_data';

import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';

void main() {
  group('web', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);
    tearDown(() => PlatformInfo.isTestingForWeb = false);

    test('toFileInfo returns FileBytesInfo when bytes are present', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final platformFile = PlatformFile(name: 'a.pdf', size: 3, bytes: bytes);

      final fileInfo = platformFile.toFileInfo();

      expect(fileInfo, isA<FileBytesInfo>());
      expect((fileInfo as FileBytesInfo).bytes, same(bytes));
      expect(fileInfo.fileName, 'a.pdf');
    });

    test('toFileInfo returns FilePlaceholderInfo when bytes are null, never reads path', () {
      final platformFile = PlatformFile(
        name: 'a.pdf',
        size: 3,
        path: '/definitely/not/on/disk/a.pdf',
      );

      final fileInfo = platformFile.toFileInfo();

      expect(fileInfo, isA<FilePlaceholderInfo>());
      expect(fileInfo.fileName, 'a.pdf');
      expect(fileInfo.fileSize, 3);
    });
  });

  group('mobile', () {
    test('toFileInfo returns FilePathInfo when path is non-empty', () {
      final platformFile = PlatformFile(name: 'a.pdf', size: 3, path: '/tmp/a.pdf');

      final fileInfo = platformFile.toFileInfo();

      expect(fileInfo, isA<FilePathInfo>());
      expect((fileInfo as FilePathInfo).filePath, '/tmp/a.pdf');
    });

    test('toFileInfo returns FilePlaceholderInfo when path is null', () {
      final platformFile = PlatformFile(name: 'a.pdf', size: 3);

      final fileInfo = platformFile.toFileInfo();

      expect(fileInfo, isA<FilePlaceholderInfo>());
      expect(fileInfo.fileName, 'a.pdf');
      expect(fileInfo.fileSize, 3);
    });

    test('toFileInfo returns FilePlaceholderInfo when path is empty', () {
      final platformFile = PlatformFile(name: 'a.pdf', size: 3, path: '');

      final fileInfo = platformFile.toFileInfo();

      expect(fileInfo, isA<FilePlaceholderInfo>());
    });
  });
}
