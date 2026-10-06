import 'dart:convert';
import 'dart:io';

import 'package:core/utils/platform_info.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/x_file_extension.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('x_file_extension_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<File> writeFile(String name, String content) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsString(content);
    return file;
  }

  group('XFileExtension::toFileInfo', () {
    test('maps name and size without reading bytes', () async {
      final file = await writeFile('note.txt', 'hello drop');

      final fileInfo = await XFile(file.path, mimeType: 'text/plain').toFileInfo();

      expect(fileInfo.fileName, 'note.txt');
      expect(fileInfo.fileSize, 'hello drop'.length);
      expect(fileInfo, isA<FilePathInfo>());
      expect(fileInfo.type, 'text/plain');
    });

    test('openRead streams the file content and can be reopened', () async {
      final file = await writeFile('note.txt', 'hello drop');

      final fileInfo = await XFile(file.path).toFileInfo();

      expect(await utf8.decodeStream(fileInfo.openRead()), 'hello drop');
      expect(await utf8.decodeStream(fileInfo.openRead()), 'hello drop');
    });

    test('openRead honours a byte range', () async {
      final file = await writeFile('note.txt', 'hello drop');

      final fileInfo = await XFile(file.path).toFileInfo();

      expect(await utf8.decodeStream(fileInfo.openRead(0, 5)), 'hello');
    });

    test('keeps the local path and no source url off web', () async {
      final file = await writeFile('note.txt', 'hello drop');

      final fileInfo = await XFile(file.path).toFileInfo();

      expect((fileInfo as FilePathInfo).filePath, file.path);
    });

    test('marks an image mime type as inline', () async {
      final file = await writeFile('photo.png', 'x');

      final image = await XFile(file.path, mimeType: 'image/png').toFileInfo();
      final text = await XFile(file.path, mimeType: 'text/plain').toFileInfo();

      expect(image.isInline, isTrue);
      expect(text.isInline, isFalse);
    });

    test('on web, a dropped file is a FileBlobInfo whose sourceUrl is the drop path', () async {
      PlatformInfo.isTestingForWeb = true;
      addTearDown(() => PlatformInfo.isTestingForWeb = false);
      final file = await writeFile('photo.png', 'png');

      final fileInfo = await XFile(file.path, mimeType: 'image/png').toFileInfo();

      expect(fileInfo, isA<FileBlobInfo>());
      expect((fileInfo as FileBlobInfo).sourceUrl, file.path);
      expect(fileInfo.fileSize, 3);
      expect(fileInfo.isInline, isTrue);
    });
  });

  group('XFileExtension::isDroppedFolder', () {
    test('is true for a directory', () async {
      final folder = await Directory('${tempDir.path}/docs').create();

      expect(await XFile(folder.path, mimeType: '').isDroppedFolder(), isTrue);
    });

    test('is false for a 0-byte file with no type', () async {
      final empty = await writeFile('LICENSE', '');

      expect(await XFile(empty.path, mimeType: '').isDroppedFolder(), isFalse);
      expect(await XFile(empty.path).isDroppedFolder(), isFalse);
    });

    test('is false for a typed or non-empty file', () async {
      final empty = await writeFile('a.txt', '');
      final filled = await writeFile('b', 'abc');

      expect(await XFile(empty.path, mimeType: 'text/plain').isDroppedFolder(), isFalse);
      expect(await XFile(filled.path, mimeType: '').isDroppedFolder(), isFalse);
    });
  });
}
