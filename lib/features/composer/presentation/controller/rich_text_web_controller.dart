
import 'dart:convert';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/code_view_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/formatting_options_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RichTextWebController extends BaseRichTextController {

  static const List<int> fontSizeList = [10, 12, 14, 15, 16, 18, 24, 36, 48, 64];
  static const int fontSizeDefault = 16;
  static const int _applyStyleDelayTimeMilliseconds = 500;

  final editorController = HtmlEditorController();

  final listTextStyleApply = RxList<RichTextStyleType>();
  final selectedTextColor = Colors.black.obs;
  final selectedTextBackgroundColor = Colors.white.obs;
  final selectedFontName = FontNameType.sansSerif.obs;
  final selectedFontSize = RxInt(fontSizeDefault);
  final codeViewState = CodeViewState.disabled.obs;
  final selectedParagraph = ParagraphType.alignLeft.obs;
  final selectedOrderList = OrderListType.bulletedList.obs;
  final focusMenuOrderList = RxBool(false);
  final focusMenuParagraph = RxBool(false);
  final menuFontStatus = DropdownMenuFontStatus.closed.obs;
  final menuHeaderStyleStatus = DropdownMenuFontStatus.closed.obs;
  final formattingOptionsState = FormattingOptionsState.disabled.obs;

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

  void onEditorSettingsChange(EditorSettings settings) {
    _updateTextStyle(settings);
    _updateFontName(settings);
    _updateTextColor(settings);
    _updateBackgroundTextColor(settings);
    _updateOrderList(settings);
    _updateParagraph(settings);
  }

  void onEditorTextSizeChanged(int? size) {
    _updateFontSize(size);
  }

  void _updateTextStyle(EditorSettings settings) {
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

    log('RichTextWebController::_updateTextStyle(): $listTextStyleApply');
  }

  void _updateFontName(EditorSettings settings) {
    log('RichTextWebController::_updateFontName():fontName: ${settings.fontName}');
    final matchedFontName = FontNameType.values.firstWhereOrNull((fontName) => fontName.value == settings.fontName);
    log('RichTextWebController::_updateFontName():matchedFontName: $matchedFontName');
    if (matchedFontName != null) {
      selectedFontName.value = matchedFontName;
    }
  }

  void _updateFontSize(int? size) {
    log('RichTextWebController::_updateFontSize():size: $size');
    if (size != null && fontSizeList.contains(size)) {
      selectedFontSize.value = size;
    }
  }

  void _updateTextColor(EditorSettings settings) {
    log('RichTextWebController::_updateTextColor():foregroundColor: ${settings.foregroundColor}');
    selectedTextColor.value = settings.foregroundColor;
  }

  void _updateBackgroundTextColor(EditorSettings settings) {
    log('RichTextWebController::_updateBackgroundTextColor():backgroundColor: ${settings.backgroundColor}');
    selectedTextBackgroundColor.value = settings.backgroundColor;
  }

  void _updateOrderList(EditorSettings settings) {
    if (settings.isOl) {
      selectedOrderList.value = OrderListType.numberedList;
    } else if (settings.isUl) {
      selectedOrderList.value = OrderListType.bulletedList;
    }
  }

  void _updateParagraph(EditorSettings settings) {
    if (settings.isAlignCenter) {
      selectedParagraph.value = ParagraphType.alignCenter;
    } else if (settings.isAlignJustify) {
      selectedParagraph.value = ParagraphType.justify;
    } else if (settings.isAlignLeft) {
      selectedParagraph.value = ParagraphType.alignLeft;
    } else if (settings.isAlignRight) {
      selectedParagraph.value = ParagraphType.alignRight;
    }
  }

  void applyRichTextStyle(BuildContext context, RichTextStyleType textStyleType) {
    switch(textStyleType) {
      case RichTextStyleType.textColor:
        openMenuSelectColor(
          context,
          selectedTextColor.value,
          onResetToDefault: () => _applyForegroundColor(Colors.black),
          onSelectColor: _applyForegroundColor
        );
        break;
      case RichTextStyleType.textBackgroundColor:
        openMenuSelectColor(
          context,
          selectedTextBackgroundColor.value,
          onResetToDefault: () => _applyBackgroundColor(Colors.white),
          onSelectColor: _applyBackgroundColor
        );
        break;
      default:
        editorController.execSummernoteAPI(textStyleType.summernoteNameAPI);
        _selectTextStyleType(textStyleType);
        break;
    }
  }

  Future<void> _applyForegroundColor(Color? selectedColor) async {
    final newColor = selectedColor ?? Colors.black;
    final colorAsString = newColor.toHexTriplet();
    log('RichTextWebController::_applyForegroundColor():colorAsString: $colorAsString');
    selectedTextColor.value = newColor;
    editorController.execSummernoteAPI(
      RichTextStyleType.textColor.summernoteNameAPI,
      value: colorAsString);
    await _requestEditorFocus();
  }

  Future<void> _applyBackgroundColor(Color? selectedColor) async {
    final newColor = selectedColor ?? Colors.white;
    final colorAsString = newColor.toHexTriplet();
    log('RichTextWebController::_applyBackgroundColor():colorAsString: $colorAsString');
    selectedTextBackgroundColor.value = newColor;
    editorController.execSummernoteAPI(
      RichTextStyleType.textBackgroundColor.summernoteNameAPI,
      value: colorAsString);
    await _requestEditorFocus();
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

  void insertImage(InlineImage inlineImage) {
    editorController.insertHtml("<div>${inlineImage.base64Uri ?? ''}</div><br>");
  }

  Future<void> applyNewFontStyle(FontNameType? newFont) async {
    final fontSelected = newFont ?? FontNameType.sansSerif;
    selectedFontName.value = fontSelected;
    editorController.execSummernoteAPI(
      RichTextStyleType.fontName.summernoteNameAPI,
      value: fontSelected.value);
    await _requestEditorFocus();
  }

  Future<void> applyNewFontSize(int? newSize) async {
    selectedFontSize.value = newSize ?? fontSizeDefault;
    editorController.setFontSize(newSize ?? fontSizeDefault);
    await _requestEditorFocus();
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
  }

  Future<void> applyHeaderStyle(HeaderStyleType? newStyle) async {
    final styleSelected = newStyle ?? HeaderStyleType.normal;
    if (styleSelected == HeaderStyleType.blockquote || styleSelected == HeaderStyleType.code) {
      editorController.execCommand(
        RichTextStyleType.headerStyle.commandAction,
        argument: styleSelected.styleValue);
    } else {
      editorController.execSummernoteAPI(styleSelected.summernoteNameAPI);
    }
    await _requestEditorFocus();
  }

  Future<void> applyParagraphType(ParagraphType newParagraph) async {
    selectedParagraph.value = newParagraph;
    editorController.execSummernoteAPI(newParagraph.summernoteNameAPI);
    menuParagraphController.hideMenu();
    await _requestEditorFocus();
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

  Future<void> applyOrderListType(OrderListType newOrderList) async {
    selectedOrderList.value = newOrderList;
    editorController.execSummernoteAPI(newOrderList.summernoteNameAPI);
    menuOrderListController.hideMenu();
    await _requestEditorFocus();
  }

  void insertImageAsBase64({required PlatformFile platformFile, int? maxWidth}) {
    if (platformFile.bytes != null) {
      final base64Data = base64Encode(platformFile.bytes!);
      editorController.insertHtml(
        '<img src="${HtmlUtils.convertBase64ToImageResourceData(base64Data: base64Data, mimeType: 'image/${platformFile.extension}')}" data-filename="${platformFile.name}" alt="Image in my signature" style="max-width: ${maxWidth != null ? '${maxWidth}px' : '100%'};"/>'
      );
    } else {
      logError("RichTextWebController::insertImageAsBase64: bytes is null");
    }
  }

  void toggleFormattingOptions() {
    final newState = isFormattingOptionsEnabled
      ? FormattingOptionsState.disabled
      : FormattingOptionsState.enabled;

    formattingOptionsState.value = newState;

    FocusManager.instance.primaryFocus?.unfocus();
    editorController.setFocus();
  }

  bool get isFormattingOptionsEnabled => formattingOptionsState.value == FormattingOptionsState.enabled;

  Future<void> _requestEditorFocus() async {
    await Future.delayed(
      const Duration(milliseconds: _applyStyleDelayTimeMilliseconds)
    );
    editorController.setFocus();
  }

  @override
  void onClose() {
    menuParagraphController.dispose();
    menuOrderListController.dispose();
    editorController.clear();
    super.onClose();
  }
}