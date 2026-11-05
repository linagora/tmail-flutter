import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/utils/file_upload_model.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';
import '../mocks/fake_file_picker.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';

class IdentityCreatorRobot extends CoreRobot {
  IdentityCreatorRobot(super.$);

  Future<void> enterName(String name) async {
    final finder = $(TextFieldBuilder).$(TextField);
    final isTextFieldFocused = finder
        .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
        .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(name);
  }

  Future<void> tapSaveIdentityButton() async {
    await $.scrollUntilVisible(finder: $(#save_identity_button));
    await $(#save_identity_button).tap();
  }

  static const double _signatureImageMaxWidth = 400;

  /// Inserts [bytes] as an inline image in the signature through the same
  /// controller entry points a user reaches (paste on web, picker on mobile).
  Future<void> addSignatureInline(Uint8List bytes, String fileName) async {
    final controller = Get.find<IdentityCreatorController>();
    final context = $.tester.element(find.byType(IdentityCreatorView));
    final imagesBefore = await _signatureImageCount(controller);
    if (PlatformInfo.isWeb) {
      await controller.onPasteImageSuccess(
        context,
        [
          FileUpload(
            base64: base64Encode(bytes),
            name: fileName,
            size: bytes.length,
            type: 'image/png',
          ),
        ],
        maxWidth: _signatureImageMaxWidth,
      );
      await _waitForNewSignatureImage(controller, imagesBefore);
      return;
    }

    // The mobile insert reads the image from a file path.
    final dir = await Directory.systemTemp.createTemp('memory_signature');
    final original = FilePickerPlatform.instance;
    try {
      final file = await File('${dir.path}/$fileName').writeAsBytes(bytes);
      FilePickerPlatform.instance = FakeFilePicker([FakePlatformFile(file)]);
      controller.pickImage(context);
      await _waitForNewSignatureImage(controller, imagesBefore);
    } finally {
      FilePickerPlatform.instance = original;
      await dir.delete(recursive: true);
    }
  }

  Future<int> _signatureImageCount(IdentityCreatorController controller) async =>
      '<img'.allMatches(await _signatureHtml(controller)).length;

  Future<void> _waitForNewSignatureImage(
    IdentityCreatorController controller,
    int imagesBefore,
  ) =>
      waitForCondition(
        () async => await _signatureImageCount(controller) > imagesBefore,
        timeout: TestTimeouts.long,
        reason: 'The signature should contain the inserted image '
            '(${_insertDiagnostics(controller)})',
      );

  // Shown only when the insert never lands, to tell a missing editor from a toast error.
  String _insertDiagnostics(IdentityCreatorController controller) {
    final texts = $.tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .toList()
        .reversed
        .take(5)
        .toList();
    final editorReady = PlatformInfo.isWeb
        ? controller.richTextWebController != null
        : controller.richTextMobileTabletController?.htmlEditorApi != null;
    return 'editor ready: $editorReady, publicAssets: '
        '${controller.publicAssetController != null}, last texts: $texts';
  }

  Future<String> _signatureHtml(IdentityCreatorController controller) async {
    if (PlatformInfo.isWeb) {
      return await controller.richTextWebController?.editorController
              .getText() ??
          '';
    }
    return await controller.richTextMobileTabletController?.richTextController
            .htmlEditorApi
            ?.getText() ??
        '';
  }
}
