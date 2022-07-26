
import 'package:collection/collection.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:dartz/dartz.dart';
import 'package:html/parser.dart' show parse;

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/code_view_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RichTextWebController extends BaseRichTextController {

  final editorController = HtmlEditorController(processNewLineAsBr: true);

  final listTextStyleApply = RxList<RichTextStyleType>();
  final selectedTextColor = Colors.black.obs;
  final selectedTextBackgroundColor = Colors.white.obs;
  final selectedFontName = FontNameType.sansSerif.obs;
  final codeViewState = CodeViewState.disabled.obs;
  final selectedParagraph = ParagraphType.alignLeft.obs;
  final focusMenuParagraph = RxBool(false);
  final menuFontStatus = DropdownMenuFontStatus.closed.obs;
  final menuHeaderStyleStatus = DropdownMenuFontStatus.closed.obs;

  final menuParagraphController = CustomPopupMenuController();

  @override
  void onReady() {
    super.onReady();
    menuParagraphController.addListener(() {
      focusMenuParagraph.value = menuParagraphController.menuIsShowing;
    });
  }

  void onEditorSettingsChange(EditorSettings settings) async {
    log('RichTextWebController::onEditorSettingsChange():');
    if (settings.isBold) {
      listTextStyleApply.add(RichTextStyleType.bold);
    } else {
      listTextStyleApply.remove(RichTextStyleType.bold);
    }

    if (settings.isItalic) {
      listTextStyleApply.add(RichTextStyleType.italic);
    } else {
      listTextStyleApply.remove(RichTextStyleType.italic);
    }

    if (settings.isUnderline) {
      listTextStyleApply.add(RichTextStyleType.underline);
    } else {
      listTextStyleApply.remove(RichTextStyleType.underline);
    }

    if (settings.isStrikethrough) {
      listTextStyleApply.add(RichTextStyleType.strikeThrough);
    } else {
      listTextStyleApply.remove(RichTextStyleType.strikeThrough);
    }
  }

  void applyRichTextStyle(BuildContext context, RichTextStyleType textStyleType) {
    switch(textStyleType) {
      case RichTextStyleType.textColor:
        openMenuSelectColor(
            context,
            selectedTextColor.value,
            onResetToDefault: () {
              final colorAsString = (Colors.black.value & 0xFFFFFF)
                  .toRadixString(16)
                  .padLeft(6, '0')
                  .toUpperCase();
              selectedTextColor.value = Colors.black;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
            },
            onSelectColor: (selectedColor) {
                final newColor = selectedColor ?? Colors.black;
                final colorAsString = (newColor.value & 0xFFFFFF)
                    .toRadixString(16)
                    .padLeft(6, '0')
                    .toUpperCase();
                log('RichTextWebController::applyRichTextStyle():selectedTextColor: colorAsString: $colorAsString');
                selectedTextColor.value = newColor;
                editorController.execCommand(
                    textStyleType.commandAction,
                    argument: colorAsString);
            }
        );
        break;
      case RichTextStyleType.textBackgroundColor:
        openMenuSelectColor(
            context,
            selectedTextBackgroundColor.value,
            onResetToDefault: () {
              final colorAsString = (Colors.white.value & 0xFFFFFF)
                  .toRadixString(16)
                  .padLeft(6, '0')
                  .toUpperCase();
              log('RichTextWebController::applyRichTextStyle():onResetToDefault: colorAsString: $colorAsString');
              selectedTextBackgroundColor.value = Colors.white;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
            },
            onSelectColor: (selectedColor) {
              final newColor = selectedColor ?? Colors.white;
              final colorAsString = (newColor.value & 0xFFFFFF)
                  .toRadixString(16)
                  .padLeft(6, '0')
                  .toUpperCase();
              log('RichTextWebController::applyRichTextStyle():textBackgroundColor: colorAsString: $colorAsString');
              selectedTextBackgroundColor.value = newColor;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
            }
        );
        break;
      default:
        editorController.execCommand(textStyleType.commandAction);
        _selectTextStyleType(textStyleType);
        break;
    }
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

  void applyNewFontStyle(FontNameType? newFont) {
    final fontSelected = newFont ?? FontNameType.sansSerif;
    selectedFontName.value = fontSelected;
    editorController.execCommand(
        RichTextStyleType.fontName.commandAction,
        argument: fontSelected.fontFamily);
  }

  bool get isMenuFontOpen => menuFontStatus.value == DropdownMenuFontStatus.open;

  bool get isMenuHeaderStyleOpen => menuHeaderStyleStatus.value == DropdownMenuFontStatus.open;

  void _closeDropdownMenuFont() {
    popBack();
  }

  void _closeDropdownMenuHeaderStyle() {
    popBack();
  }

  bool get codeViewEnabled => codeViewState.value == CodeViewState.enabled;

  Future<bool> get isActivatedCodeView => editorController.isActivatedCodeView();

  void setFullScreenEditor() {
    editorController.setFullScreen();
  }

  void setEnableCodeView() async {
    final isActivated = await isActivatedCodeView;
    if (codeViewEnabled && !isActivated) {
      toggleCodeView();
    }
  }

  void toggleCodeView() async {
    final isActivated = await isActivatedCodeView;
    final newCodeViewState = isActivated ? CodeViewState.disabled : CodeViewState.enabled;
    codeViewState.value = newCodeViewState;
    _selectTextStyleType(RichTextStyleType.codeView);
    editorController.toggleCodeView();
    if (isActivated) {
      setFullScreenEditor();
      editorController.setFullScreen();
    }
  }

  void applyHeaderStyle(HeaderStyleType? newStyle) {
    final styleSelected = newStyle ?? HeaderStyleType.normal;
    editorController.execCommand(
        RichTextStyleType.headerStyle.commandAction,
        argument: styleSelected.styleValue);
  }

  void applyParagraphType(ParagraphType newParagraph) {
    selectedParagraph.value = newParagraph;
    editorController.execCommand(newParagraph.commandAction);
    menuParagraphController.hideMenu();
  }

  void closeAllMenuPopup() {
    if (isMenuFontOpen) {
      _closeDropdownMenuFont();
    }
    if (isMenuHeaderStyleOpen) {
      _closeDropdownMenuHeaderStyle();
    }
    if (menuParagraphController.menuIsShowing) {
      menuParagraphController.hideMenu();
    }
  }

  @override
  void onClose() {
    menuParagraphController.dispose();
    super.onClose();
  }
}