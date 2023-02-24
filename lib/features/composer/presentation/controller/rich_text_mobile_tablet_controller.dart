
import 'package:core/utils/app_logger.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';

class RichTextMobileTabletController extends BaseRichTextController {
  HtmlEditorApi? htmlEditorApi;

  void insertImage(InlineImage image, {double? maxWithEditor}) async {
    log('RichTextMobileTabletController::insertImage(): $image | maxWithEditor: $maxWithEditor');
    if (image.source == ImageSource.network) {
      htmlEditorApi?.insertImageLink(image.link!);
    } else {
      await htmlEditorApi?.moveCursorAtLastNode();
      await htmlEditorApi?.insertHtml(image.base64Uri ?? '');
    }
  }

  void applyHeaderStyle(HeaderStyleType? newStyle) {
    final styleSelected = newStyle ?? HeaderStyleType.normal;
    htmlEditorApi?.formatHeader(styleSelected.styleValue);
  }
}
