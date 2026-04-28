import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RichTextMobileTabletController extends GetxController {
  HtmlEditorApi? htmlEditorApi;

  final RichTextController richTextController = RichTextController();

  Future<bool> get isEditorFocused async => await htmlEditorApi?.hasFocus() ?? false;

  Future<void> focus() async {
    try {
      await htmlEditorApi?.webViewController.evaluateJavascript(source: '''
      (() => {
        const editor = document.getElementById('editor');
        if (editor && typeof editor.focus === 'function') {
          editor.focus();
        }
      })();''');
    } catch (e) {
      logWarning('RichTextMobileTabletController::focus:Exception: $e');
    }
  }

  void insertImage(InlineImage inlineImage) async {
    await restoreMobileEditorFocus();
    if (inlineImage.base64Uri?.isNotEmpty == true) {
      await htmlEditorApi?.insertHtml('${inlineImage.base64Uri ?? ''}<br/><br/>');
    }
  }

  Future<void> restoreMobileEditorFocus() async {
    if (!PlatformInfo.isMobile) return;
    try {
      final selectionRangeAvailable =
          await htmlEditorApi?.isSelectionRangeAvailable();
      if (selectionRangeAvailable == true) {
        await htmlEditorApi?.restoreSelectionRange();
      } else {
        await htmlEditorApi?.requestFocusFirstChild();
      }
    } catch (e) {
      log('RichTextMobileTabletController::insertImage(): $e');
    }
  }

  void applyHeaderStyle(HeaderStyleType? newStyle) {
    final styleSelected = newStyle ?? HeaderStyleType.normal;
    htmlEditorApi?.formatHeader(styleSelected.styleValue);
  }

  void insertImageData({required PlatformFile platformFile, int? maxWidth}) async {
    try {
      if (platformFile.path?.isNotEmpty == true) {
        final bytesData = await File(platformFile.path!).readAsBytes();
        await htmlEditorApi?.insertImageData(
          bytesData,
          HtmlUtils.validateHtmlImageResourceMimeType('image/${platformFile.extension}'),
          maxWidth: maxWidth
        );
      } else {
        logWarning('RichTextMobileTabletController::insertImageData: path is null');
      }
    } catch (e) {
      logWarning('RichTextMobileTabletController::insertImageData:Exception: $e');
    }
  }

  Future<void> showFormatStyleBottomSheet({
    required BuildContext context,
    required RichTextController? richTextController
  }) async {
    if (PlatformInfo.isAndroid) {
      await htmlEditorApi?.hideKeyboard();
    } else if (PlatformInfo.isIOS) {
      await htmlEditorApi?.unfocus();
    }

    if (context.mounted) {
      richTextController?.showFormatOptionBottomSheet(
        context: context,
        formatLabel: AppLocalizations.of(context).titleFormat,
        quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
        foregroundLabel: AppLocalizations.of(context).titleForeground,
        backgroundLabel: AppLocalizations.of(context).titleBackground,
      );
    }
  }

  @override
  void onClose() {
    richTextController.dispose();
    if (kDebugMode) {
      try {
        htmlEditorApi?.webViewController.dispose();
      } catch (e) {
        logWarning('Dispose error: $e');
      }
    } else {
      htmlEditorApi?.webViewController.dispose();
    }
    htmlEditorApi = null;
    super.onClose();
  }
}
