import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';

void main() {
  test('same name and size on different sources are not equal', () {
    final bytes = FileBytesInfo(bytes: Uint8List(3), fileName: 'a.bin');
    const path = FilePathInfo(fileName: 'a.bin', fileSize: 3, filePath: '/tmp/a.bin');
    expect(bytes == path, isFalse);
  });

  test('mimeType of a FilePathInfo comes from its path', () {
    const file = FilePathInfo(fileName: 'noext', fileSize: 1, filePath: '/tmp/a.pdf');
    expect(file.mimeType, 'application/pdf');
  });

  test('mimeType of a FileBytesInfo sniffs its header bytes', () {
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    expect(FileBytesInfo(bytes: png, fileName: 'noext').mimeType, 'image/png');
  });

  test('FileBytesInfo defaults name to empty and size to byte length', () {
    final file = FileBytesInfo(bytes: Uint8List(5));
    expect(file.fileName, '');
    expect(file.fileSize, 5);
  });
}
