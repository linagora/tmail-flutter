
import 'package:collection/collection.dart';
import 'package:core/presentation/views/dialog/color_picker_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:html/parser.dart' show parse;

abstract class BaseRichTextController extends GetxController {

  void openMenuSelectColor(
    BuildContext context,
    Color currentColor,
    {
      Function(Color?)? onSelectColor,
      VoidCallback? onResetToDefault,
    }
  ) async {
    await ColorPickerDialogBuilder(
        context,
        currentColor,
        title: AppLocalizations.of(context).chooseAColor,
        textActionSetColor: AppLocalizations.of(context).setColor,
        textActionResetDefault: AppLocalizations.of(context).resetToDefault,
        textActionCancel: AppLocalizations.of(context).cancel,
        cancelActionCallback: () => popBack(),
        resetToDefaultActionCallback: () {
          onResetToDefault?.call();
          popBack();
        },
        setColorActionCallback: (selectedColor) {
          onSelectColor?.call(selectedColor);
          popBack();
        }
    ).show();
  }

  Future<Tuple2<String, List<Attachment>>> refactorContentHasInlineImage(
      String emailContent,
      Map<String, Attachment> mapInlineAttachments
  ) async {
    final document = parse(emailContent);
    final listImgTag = document.querySelectorAll('img[src^="data:image/"][id^="cid:"]');
    final listInlineAttachment = await Future.wait(listImgTag.map((imgTag) async {
      final idImg = imgTag.attributes['id'];
      final cid = idImg!.replaceFirst('cid:', '').trim();
      log('BaseRichTextController::refactorContentHasInlineImage(): $cid');
      imgTag.attributes['src'] = 'cid:$cid';
      imgTag.attributes.remove('id');
      return cid;
    })).then((listCid) {
      log('BaseRichTextController::refactorContentHasInlineImage(): $listCid');
      final listInlineAttachment = listCid
          .whereNotNull()
          .map((cid) => mapInlineAttachments[cid])
          .whereNotNull()
          .toList();
      return listInlineAttachment;
    });
    final newContent = document.body?.innerHtml ?? emailContent;
    log('BaseRichTextController::refactorContentHasInlineImage(): $newContent');
    log('BaseRichTextController::refactorContentHasInlineImage(): listInlineAttachment: $listInlineAttachment');
    return Tuple2(newContent, listInlineAttachment);
  }
}