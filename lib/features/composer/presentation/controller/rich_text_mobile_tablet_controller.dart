import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';

class RichTextMobileTabletController extends GetxController {
  HtmlEditorApi? htmlEditorApi;
  final listTextStyleApply = RxList<RichTextStyleType>();

  void listenHtmlEditorApi() {
    htmlEditorApi?.onFormatSettingsChanged = (formatSettings) {
      listTextStyleApply.clear();
      if (formatSettings.isBold) {
        listTextStyleApply.add(RichTextStyleType.bold);
      }

      if (formatSettings.isItalic) {
        listTextStyleApply.add(RichTextStyleType.italic);
      }

      if (formatSettings.isUnderline) {
        listTextStyleApply.add(RichTextStyleType.underline);
      }

      if (formatSettings.isStrikeThrough) {
        listTextStyleApply.add(RichTextStyleType.strikeThrough);
      }
    };
  }

  selectTextStyleType(RichTextStyleType richTextStyleType) {
    if (listTextStyleApply.contains(richTextStyleType)) {
      listTextStyleApply.remove(richTextStyleType);
    } else {
      listTextStyleApply.add(richTextStyleType);
    }
  }

  bool isTextStyleTypeSelected(RichTextStyleType richTextStyleType) {
    return listTextStyleApply.contains(richTextStyleType);
  }
}
