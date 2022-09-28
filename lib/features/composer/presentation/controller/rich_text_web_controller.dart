
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/code_view_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
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
  final selectedOrderList = OrderListType.bulletedList.obs;
  final focusMenuOrderList = RxBool(false);
  final focusMenuParagraph = RxBool(false);
  final menuFontStatus = DropdownMenuFontStatus.closed.obs;
  final menuHeaderStyleStatus = DropdownMenuFontStatus.closed.obs;

  final menuParagraphController = CustomPopupMenuController();
  final menuOrderListController = CustomPopupMenuController();

  @override
  void onReady() {
    super.onReady();
    menuParagraphController.addListener(() {
      focusMenuParagraph.value = menuParagraphController.menuIsShowing;
    });
    menuOrderListController.addListener(() {
      focusMenuOrderList.value = menuOrderListController.menuIsShowing;
    });
  }

  void onEditorSettingsChange(EditorSettings settings) async {
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

    log('RichTextWebController::onEditorSettingsChange(): $listTextStyleApply');
  }

  void applyRichTextStyle(BuildContext context, RichTextStyleType textStyleType) {
    switch(textStyleType) {
      case RichTextStyleType.textColor:
        openMenuSelectColor(
            context,
            selectedTextColor.value,
            onResetToDefault: () {
              final colorAsString = Colors.black.toHexTriplet();
              selectedTextColor.value = Colors.black;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
              editorController.setFocus();
            },
            onSelectColor: (selectedColor) {
                final newColor = selectedColor ?? Colors.black;
                final colorAsString = newColor.toHexTriplet();
                log('RichTextWebController::applyRichTextStyle():selectedTextColor: colorAsString: $colorAsString');
                selectedTextColor.value = newColor;
                editorController.execCommand(
                    textStyleType.commandAction,
                    argument: colorAsString);
                editorController.setFocus();
            }
        );
        break;
      case RichTextStyleType.textBackgroundColor:
        openMenuSelectColor(
            context,
            selectedTextBackgroundColor.value,
            onResetToDefault: () {
              final colorAsString = Colors.white.toHexTriplet();
              log('RichTextWebController::applyRichTextStyle():onResetToDefault: colorAsString: $colorAsString');
              selectedTextBackgroundColor.value = Colors.white;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
              editorController.setFocus();
            },
            onSelectColor: (selectedColor) {
              final newColor = selectedColor ?? Colors.white;
              final colorAsString = newColor.toHexTriplet();
              log('RichTextWebController::applyRichTextStyle():textBackgroundColor: colorAsString: $colorAsString');
              selectedTextBackgroundColor.value = newColor;
              editorController.execCommand(
                  textStyleType.commandAction,
                  argument: colorAsString);
              editorController.setFocus();
            }
        );
        break;
      default:
        editorController.execCommand(textStyleType.commandAction);
        _selectTextStyleType(textStyleType);
        editorController.setFocus();
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

  void insertImage(InlineImage image) async {
    log('RichTextWebController::insertImage(): $image');
    if (image.source == ImageSource.network) {
      editorController.insertNetworkImage(image.link!);
    } else {
      editorController.insertHtml(image.base64Uri ?? '');
    }
  }

  void applyNewFontStyle(FontNameType? newFont) {
    final fontSelected = newFont ?? FontNameType.sansSerif;
    selectedFontName.value = fontSelected;
    editorController.execCommand(
        RichTextStyleType.fontName.commandAction,
        argument: fontSelected.fontFamily);
    editorController.setFocus();
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
    editorController.setFocus();
  }

  void applyParagraphType(ParagraphType newParagraph) {
    selectedParagraph.value = newParagraph;
    editorController.execCommand(newParagraph.commandAction);
    menuParagraphController.hideMenu();
    editorController.setFocus();
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
    if (menuOrderListController.menuIsShowing) {
      menuOrderListController.hideMenu();
    }
  }

  void applyOrderListType(OrderListType newOrderList) {
    selectedOrderList.value = newOrderList;
    editorController.execCommand(newOrderList.commandAction);
    menuOrderListController.hideMenu();
    editorController.setFocus();
  }

  @override
  void onClose() {
    menuParagraphController.dispose();
    menuOrderListController.dispose();
    super.onClose();
  }
}