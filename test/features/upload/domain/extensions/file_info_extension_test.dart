import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/file_info_extension.dart';

void main() {
  test('withInline keeps the openRead and sourceUrl byte sources', () async {
    const sourceBytes = [1, 2, 3];
    const sourceUrl = 'blob:https://example.com/image-id';
    final inline = FileInfo(
      fileName: 'image.png',
      fileSize: sourceBytes.length,
      openRead: ([start, end]) => Stream<List<int>>.value(sourceBytes),
      sourceUrl: sourceUrl,
      type: 'image/png',
    ).withInline();

    expect(inline.isInline, isTrue);
    expect(inline.sourceUrl, sourceUrl);
    expect(await inline.openRead!().toList(), [sourceBytes]);
  });
}
