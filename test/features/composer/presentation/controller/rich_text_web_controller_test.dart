import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';

import 'rich_text_web_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HtmlEditorController>()])
void main() {
  group('RichTextWebController::insertImageAsBase64', () {
    late MockHtmlEditorController editorController;
    late RichTextWebController controller;

    setUp(() {
      editorController = MockHtmlEditorController();
      controller = RichTextWebController(editorController: editorController);
    });

    test('does not insert an image when the file has no readable bytes', () async {
      const fileInfo = FilePlaceholderInfo(fileName: 'a.png', fileSize: 3);

      await expectLater(controller.insertImageAsBase64(fileInfo: fileInfo), completes);
      verifyNever(editorController.insertHtml(any));
    });

    test('does not insert an image when the file bytes are empty', () async {
      final fileInfo = FileBytesInfo(bytes: Uint8List(0), fileName: 'a.png');

      await expectLater(controller.insertImageAsBase64(fileInfo: fileInfo), completes);
      verifyNever(editorController.insertHtml(any));
    });

    test('inserts an image when the file has bytes', () async {
      final fileInfo = FileBytesInfo(bytes: Uint8List.fromList([1, 2, 3]), fileName: 'a.png');

      await controller.insertImageAsBase64(fileInfo: fileInfo);
      verify(editorController.insertHtml(argThat(contains('data-filename="a.png"')))).called(1);
    });
  });

  group('RichTextWebController::buildInlineImageHtml', () {
    test('escapes the file name before it is written to the data-filename attribute', () {
      final html = RichTextWebController.buildInlineImageHtml(
        base64Data: 'AAAA',
        mimeType: 'image/png',
        fileName: '"><script>alert(1)</script>.png',
      );

      expect(html, isNot(contains('<script>')));
      expect(html, contains('data-filename="&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;.png"'));
    });

    test('keeps a normal file name unchanged', () {
      final html = RichTextWebController.buildInlineImageHtml(
        base64Data: 'AAAA',
        mimeType: 'image/png',
        fileName: 'signature.png',
      );

      expect(html, contains('data-filename="signature.png"'));
    });

    test('escapes the MIME type before it is written to the src and data-mimetype attributes', () {
      final html = RichTextWebController.buildInlineImageHtml(
        base64Data: 'AAAA',
        mimeType: 'image/png" onerror="alert(1)',
        fileName: 'signature.png',
      );

      expect(html, isNot(contains('" onerror="')));
      expect(html, contains('data-mimetype="image/png&quot; onerror=&quot;alert(1)"'));
      expect(html, contains('src="data:image/png&quot; onerror=&quot;alert(1);base64,AAAA"'));
    });
  });
}
