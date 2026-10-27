import 'dart:typed_data';

import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/code_view_state.dart';

import '../fixtures/code_view_html_fixtures.dart';
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

  group('RichTextWebController::toggleCodeView', () {
    late MockHtmlEditorController editorController;
    late RichTextWebController controller;

    setUp(() {
      editorController = MockHtmlEditorController();
      controller = RichTextWebController(editorController: editorController);
    });

    test('enables code view without reading or rewriting the editor HTML', () async {
      when(editorController.isActivatedCodeView()).thenAnswer((_) async => false);

      controller.toggleCodeView();
      await untilCalled(editorController.toggleCodeView());

      expect(controller.codeViewEnabled, isTrue);
      verifyNever(editorController.getText());
      verifyNever(editorController.setText(any));
      verify(editorController.toggleCodeView()).called(1);
    });

    test('leaving code view still toggles the editor and disables code view', () async {
      when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
      when(editorController.getText()).thenAnswer((_) async => benignComposerHtml);

      controller.toggleCodeView();
      await untilCalled(editorController.toggleCodeView());

      expect(controller.codeViewEnabled, isFalse);
      verify(editorController.toggleCodeView()).called(1);
      verify(editorController.evaluateJavascriptWeb(HtmlUtils.recalculateEditorHeight().name)).called(1);
    });

    test('sanitizes GHSA-73vq-c7p5-pvp4 HTML before leaving code view', () async {
      when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
      when(editorController.getText()).thenAnswer((_) async => ghsaEmbedCodeXssPayload);

      controller.toggleCodeView();
      await untilCalled(editorController.toggleCodeView());

      final captured = verify(editorController.setText(captureAny)).captured.single as String;
      final sanitized = captured.toLowerCase();
      expect(sanitized, isNot(contains('<script')));
      expect(sanitized, isNot(contains('onerror')));
      expect(sanitized, isNot(contains('onload')));
      expect(sanitized, isNot(contains('javascript:')));
      expect(sanitized, contains('visible text'));
      verify(editorController.getText()).called(1);
      verify(editorController.toggleCodeView()).called(1);
    });

    test('does not leave code view when the editor HTML cannot be read', () async {
      when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
      when(editorController.getText()).thenAnswer((_) async => throw Exception('editor unavailable'));
      controller.codeViewState.value = CodeViewState.enabled;

      controller.toggleCodeView();
      await untilCalled(editorController.isActivatedCodeView());
      await untilCalled(editorController.getText());
      await Future<void>.delayed(Duration.zero);

      expect(controller.codeViewEnabled, isTrue);
      verifyNever(editorController.setText(any));
      verifyNever(editorController.toggleCodeView());
    });
  });
}
