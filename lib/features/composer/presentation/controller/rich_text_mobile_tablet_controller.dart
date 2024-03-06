import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';

class RichTextMobileTabletController extends BaseRichTextController {
  HtmlEditorApi? htmlEditorApi;

  void insertImage(
    InlineImage image,
    {
      double? maxWithEditor,
      bool fromFileShare = false
    }
  ) async {
    log('RichTextMobileTabletController::insertImage(): $image | maxWithEditor: $maxWithEditor | $fromFileShare');
    if (image.source == ImageSource.network) {
      htmlEditorApi?.insertImageLink(image.link!);
    } else {
      if (fromFileShare) {
        await htmlEditorApi?.moveCursorAtLastNode();
      }
      await htmlEditorApi?.insertHtml(image.base64Uri ?? '');
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
}
