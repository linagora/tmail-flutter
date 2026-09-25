import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';

void main() {
  group('RichTextWebController::insertImageAsBase64', () {
    late RichTextWebController controller;

    setUp(() => controller = RichTextWebController());

    test('completes without throwing when the file has no readable bytes', () async {
      const fileInfo = FilePlaceholderInfo(fileName: 'a.png', fileSize: 3);

      await expectLater(controller.insertImageAsBase64(fileInfo: fileInfo), completes);
    });

    test('completes without throwing when the file bytes are empty', () async {
      final fileInfo = FileBytesInfo(bytes: Uint8List(0), fileName: 'a.png');

      await expectLater(controller.insertImageAsBase64(fileInfo: fileInfo), completes);
    });
  });
}
