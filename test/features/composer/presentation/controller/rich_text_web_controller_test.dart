import 'dart:async';
import 'dart:typed_data';

import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/code_view_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../fixtures/code_view_html_fixtures.dart';
import 'rich_text_web_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HtmlEditorController>(), MockSpec<AppToast>()])
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

    test('writes an empty paragraph when sanitizing removes all the code view HTML', () async {
      when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
      when(editorController.getText()).thenAnswer((_) async => scriptOnlyEmbedCodePayload);

      controller.toggleCodeView();
      await untilCalled(editorController.toggleCodeView());

      verify(editorController.setText('<p><br></p>')).called(1);
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

    group('when the editor never answers', () {
      const replyTimeout = Duration(milliseconds: 10);

      setUp(() {
        controller = RichTextWebController(
          editorController: editorController,
          editorReplyTimeout: replyTimeout,
        );
      });

      test('gives up on the code view state and accepts a later toggle', () async {
        when(editorController.isActivatedCodeView()).thenAnswer((_) => Completer<bool>().future);

        controller.toggleCodeView();
        await Future<void>.delayed(replyTimeout * 3);

        when(editorController.isActivatedCodeView()).thenAnswer((_) async => false);
        controller.toggleCodeView();
        await untilCalled(editorController.toggleCodeView());

        expect(controller.codeViewEnabled, isTrue);
        verify(editorController.toggleCodeView()).called(1);
      });

      test('stays in code view when reading the HTML times out', () async {
        when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
        when(editorController.getText()).thenAnswer((_) => Completer<String>().future);
        controller.codeViewState.value = CodeViewState.enabled;

        controller.toggleCodeView();
        await Future<void>.delayed(replyTimeout * 3);

        expect(controller.codeViewEnabled, isTrue);
        verifyNever(editorController.setText(any));
        verifyNever(editorController.toggleCodeView());
      });
    });

    group('error toast', () {
      late MockAppToast appToast;

      setUp(() {
        appToast = MockAppToast();
        Get.put<AppToast>(appToast);
        addTearDown(() => Get.delete<AppToast>());
      });

      testWidgets('shows an unknown error toast when the editor HTML cannot be read', (tester) async {
        final context = await _pumpOverlayContext(tester);
        when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
        when(editorController.getText()).thenAnswer((_) async => throw Exception('editor unavailable'));

        controller.toggleCodeView();
        await tester.pump();

        verify(appToast.showToastErrorMessage(context, AppLocalizations.of(context).unknownError)).called(1);
      });

      testWidgets('shows an unknown error toast when the code view state never comes back', (tester) async {
        controller = RichTextWebController(
          editorController: editorController,
          editorReplyTimeout: _replyTimeout,
        );
        final context = await _pumpOverlayContext(tester);
        when(editorController.isActivatedCodeView()).thenAnswer((_) => Completer<bool>().future);

        controller.toggleCodeView();
        await tester.pump(_replyTimeout);

        verify(appToast.showToastErrorMessage(context, AppLocalizations.of(context).unknownError)).called(1);
      });

      testWidgets('shows an unknown error toast and stays in code view when the HTML never comes back', (tester) async {
        controller = RichTextWebController(
          editorController: editorController,
          editorReplyTimeout: _replyTimeout,
        );
        final context = await _pumpOverlayContext(tester);
        when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
        when(editorController.getText()).thenAnswer((_) => Completer<String>().future);
        controller.codeViewState.value = CodeViewState.enabled;

        controller.toggleCodeView();
        await tester.pump(_replyTimeout);

        verify(appToast.showToastErrorMessage(context, AppLocalizations.of(context).unknownError)).called(1);
        expect(controller.codeViewEnabled, isTrue);
        verifyNever(editorController.setText(any));
        verifyNever(editorController.toggleCodeView());
      });

      testWidgets('does not show a toast when leaving code view succeeds', (tester) async {
        await _pumpOverlayContext(tester);
        when(editorController.isActivatedCodeView()).thenAnswer((_) async => true);
        when(editorController.getText()).thenAnswer((_) async => benignComposerHtml);

        controller.toggleCodeView();
        await tester.pump();

        verify(editorController.toggleCodeView()).called(1);
        verifyNever(appToast.showToastErrorMessage(any, any));
      });
    });
  });
}

const _replyTimeout = Duration(seconds: 1);

Future<BuildContext> _pumpOverlayContext(WidgetTester tester) async {
  await tester.pumpWidget(const GetMaterialApp(
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: SizedBox.shrink(),
  ));
  await tester.pumpAndSettle();
  return currentOverlayContext!;
}
