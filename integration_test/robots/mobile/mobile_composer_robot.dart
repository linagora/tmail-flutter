import 'dart:io';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../mocks/fake_file_picker.dart';
import '../abstract/abstract_composer_robot.dart';
import '../composer_robot.dart';

class MobileComposerRobot extends ComposerRobot implements AbstractComposerRobot {
  MobileComposerRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectComposerViewVisible() async {
    await $.waitUntilVisible($(ComposerView));
  }

  @override
  Future<void> addRecipient(PrefixEmailAddress prefix, String email) =>
      addRecipientIntoField(prefixEmailAddress: prefix, email: email);

  @override
  Future<void> send() => sendEmail(ImagePaths());

  /// Places cursor immediately before the `<blockquote>` element via JS,
  /// simulating a user tap in the composing area above the quoted reply body.
  @override
  Future<void> focusEditorAboveReplyBody() async {
    final controller = Get.find<ComposerController>();
    await _waitForBlockquote(controller);
    await controller.htmlEditorApi?.webViewController.evaluateJavascript(
      source: '''
        (function() {
          const editor = document.getElementById('editor');
          const blockquote = editor.querySelector('blockquote');
          if (!blockquote) return;
          const range = document.createRange();
          range.setStartBefore(blockquote);
          range.collapse(true);
          const sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);
          editor.focus();
        })();
      ''',
    );
  }

  /// Injects [FakeFilePicker], calls the real [ComposerController.insertImage]
  /// (which triggers `storeSelectionRange()`), waits for the base64 download,
  /// then polls the editor HTML until `data:image/` appears (3 retries,
  /// exponential backoff: 1 s → 2 s). Restores the original picker in `finally`.
  @override
  Future<void> addInlineAtCursorPosition(File file) async {
    final controller = Get.find<ComposerController>();
    final context = $.tester.element(find.byType(ComposerView));
    final fakeResult = FilePickerResult([
      PlatformFile(
        name: file.path.split('/').last,
        size: await file.length(),
        path: file.path,
      ),
    ]);
    final original = FilePicker.platform;
    try {
      FilePicker.platform = FakeFilePicker(fakeResult);
      await controller.insertImage(context, 400.0);
      await controller.viewState.stream.firstWhere((state) => state.fold(
        (failure) => failure is DownloadImageAsBase64Failure,
        (success) => success is DownloadImageAsBase64Success,
      ));
    } finally {
      FilePicker.platform = original;
    }
    await _waitForInlineImage(controller);
  }

  /// Polls the editor HTML until `data:image/` is present.
  /// Max 3 attempts with exponential backoff: 1 s → 2 s.
  Future<void> _waitForInlineImage(ComposerController controller) async {
    const maxAttempts = 3;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await $.pumpAndTrySettle(
          duration: Duration(milliseconds: 500 * (1 << attempt)),
        );
      }
      final html = await controller.getContentInEditor();
      if (html.contains('data:image/')) return;
    }
  }

  /// Polls the editor DOM until `.tmail-signature` appears.
  /// Max 3 attempts with exponential backoff: 1 s → 2 s.
  @override
  Future<void> waitForSignatureToLoad() async {
    const maxAttempts = 3;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await $.pumpAndTrySettle(
          duration: Duration(milliseconds: 500 * (1 << attempt)),
        );
      }
      final ready = await Get.find<ComposerController>()
          .htmlEditorApi
          ?.webViewController
          .evaluateJavascript(
            source:
                "document.getElementById('editor')?.querySelector('.tmail-signature') != null",
          );
      if (ready == true) return;
    }
  }

  /// Polls until `<blockquote>` appears in the editor DOM.
  /// Max 3 attempts with exponential backoff: 500 ms → 1 s → 2 s.
  Future<void> _waitForBlockquote(ComposerController controller) async {
    const maxAttempts = 3;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await $.pumpAndTrySettle(
          duration: Duration(milliseconds: 500 * (1 << attempt)),
        );
      }
      final ready = await controller.htmlEditorApi?.webViewController
          .evaluateJavascript(
            source: "document.getElementById('editor')?.querySelector('blockquote') != null",
          );
      if (ready == true) return;
    }
  }
}
