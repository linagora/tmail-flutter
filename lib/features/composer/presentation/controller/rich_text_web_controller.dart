
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';

class RichTextWebController extends GetxController {

  final editorController = HtmlEditorController(processNewLineAsBr: true);

  final listTextStyleApply = RxList<RichTextStyleType>();

  void onEditorSettingsChange(EditorSettings settings) {
    log('RichTextWebController::onEditorSettingsChange():');
    listTextStyleApply.clear();
    if (settings.isBold) {
      listTextStyleApply.add(RichTextStyleType.bold);
    }

    if (settings.isItalic) {
      listTextStyleApply.add(RichTextStyleType.italic);
    }

    if (settings.isUnderline) {
      listTextStyleApply.add(RichTextStyleType.underline);
    }
  }

  void applyRichTextStyle(RichTextStyleType textStyleType) {
    editorController.execCommand(textStyleType.commandAction);
    _selectTextStyleType(textStyleType);
  }

  void _selectTextStyleType(RichTextStyleType textStyleType) {
    if (listTextStyleApply.contains(textStyleType)) {
      listTextStyleApply.remove(textStyleType);
    } else {
      listTextStyleApply.add(textStyleType);
    }
  }

  bool isTextStyleTypeSelected(RichTextStyleType richTextStyleType) =>
      listTextStyleApply.contains(richTextStyleType);
}