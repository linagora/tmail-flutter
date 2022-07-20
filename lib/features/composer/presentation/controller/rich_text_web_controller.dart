
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:html/parser.dart' show parse;

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
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

    if (settings.isStrikethrough) {
      listTextStyleApply.add(RichTextStyleType.strikeThrough);
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

  void insertImage(InlineImage image, {double? maxWithEditor}) async {
    log('RichTextWebController::insertImage(): $image | maxWithEditor: $maxWithEditor');
    if (image.source == ImageSource.network) {
      editorController.insertNetworkImage(image.link!);
    } else {
      final htmlContent = await image.generateImgTagHtml(maxWithEditor: maxWithEditor);
      log('RichTextWebController::insertImage(): $htmlContent');
      editorController.insertHtml(htmlContent);
    }
  }

  Future<Tuple2<String, List<Attachment>>> refactorContentHasInlineImage(
      String emailContent,
      Map<String, Attachment> mapInlineAttachments
  ) async {
    final document = parse(emailContent);
    final listImgTag = document.querySelectorAll('img[src^="data:image/"]');
    final listInlineAttachment = await Future.wait(listImgTag.map((imgTag) async {
      final cid = imgTag.attributes['id'];
      log('RichTextWebController::refactorContentHasInlineImage(): cid: $cid');
      imgTag.attributes['src'] = 'cid:$cid';
      imgTag.attributes.remove('id');
      return cid;
    })).then((listCid) {
      log('RichTextWebController::refactorContentHasInlineImage(): $listCid');
      final listInlineAttachment = listCid
          .whereNotNull()
          .map((cid) => mapInlineAttachments[cid])
          .whereNotNull()
          .toList();
      return listInlineAttachment;
    });
    final newContent = document.body?.innerHtml ?? emailContent;
    log('RichTextWebController::refactorContentHasInlineImage(): $newContent');
    log('RichTextWebController::refactorContentHasInlineImage(): listInlineAttachment: $listInlineAttachment');
    return Tuple2(newContent, listInlineAttachment);
  }
}