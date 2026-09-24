import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/file_info_extension.dart';

void main() {
  test('withInline keeps a FilePathInfo as a FilePathInfo', () {
    const file = FilePathInfo(fileName: 'a.pdf', fileSize: 3, filePath: '/tmp/a.pdf');

    final inline = file.withInline();

    expect(inline, isA<FilePathInfo>());
    expect(inline.isInline, isTrue);
    expect((inline as FilePathInfo).filePath, '/tmp/a.pdf');
  });

  test('withInline keeps a FileBytesInfo as a FileBytesInfo', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final file = FileBytesInfo(bytes: bytes, fileName: 'a.png');

    final inline = file.withInline();

    expect(inline, isA<FileBytesInfo>());
    expect(inline.isInline, isTrue);
    expect((inline as FileBytesInfo).bytes, same(bytes));
  });

  test('withInline keeps a FilePlaceholderInfo as a FilePlaceholderInfo', () {
    const file = FilePlaceholderInfo(fileName: 'a.pdf', fileSize: 3);

    final inline = file.withInline();

    expect(inline, isA<FilePlaceholderInfo>());
    expect(inline.isInline, isTrue);
    expect(inline.fileName, 'a.pdf');
    expect(inline.fileSize, 3);
  });
}
