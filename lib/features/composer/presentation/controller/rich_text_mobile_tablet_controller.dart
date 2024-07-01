import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RichTextMobileTabletController extends BaseRichTextController {
  HtmlEditorApi? htmlEditorApi;

  final RichTextController richTextController = RichTextController();

  Future<bool> get isEditorFocused async => await htmlEditorApi?.hasFocus() ?? false;

  void insertImage(InlineImage inlineImage) async {
    final isFocused = await isEditorFocused;
    log('RichTextMobileTabletController::insertImage: isEditorFocused = $isFocused');
    if (!isFocused) {
      await htmlEditorApi?.requestFocusLastChild();
    }
    if (inlineImage.base64Uri?.isNotEmpty == true) {
      await htmlEditorApi?.insertHtml('${inlineImage.base64Uri ?? ''}<br/><br/>');
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
        logError('RichTextMobileTabletController::insertImageData: path is null');
      }
    } catch (e) {
      logError('RichTextMobileTabletController::insertImageData:Exception: $e');
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
    htmlEditorApi = null;
    super.onClose();
  }
}
