import 'package:core/core.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/base_rich_text_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';

class RichTextMobileTabletController extends BaseRichTextController {
  HtmlEditorApi? htmlEditorApi;
  final listTextStyleApply = RxList<RichTextStyleType>();
  final selectedTextColor = Colors.black.obs;
  final selectedTextBackgroundColor = Colors.white.obs;
  final selectedFontName = SafeFont.sansSerif.obs;

  final  menuHeaderStyleStatus = DropdownMenuFontStatus.closed.obs;

  bool get isMenuHeaderStyleOpen => menuHeaderStyleStatus.value == DropdownMenuFontStatus.open;

  final selectedParagraph = ParagraphType.alignLeft.obs;
  final selectedOrderList = OrderListType.bulletedList.obs;

  final focusMenuOrderList = RxBool(false);
  final focusMenuParagraph = RxBool(false);

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

  void applyRichTextStyle(
      BuildContext context, RichTextStyleType textStyleType) async {
    switch (textStyleType) {
      case RichTextStyleType.textColor:
        openMenuSelectColor(context, selectedTextColor.value,
            onResetToDefault: () {
          selectedTextColor.value = Colors.black;
          htmlEditorApi?.setColorDocumentForeground(selectedTextColor.value);
        }, onSelectColor: (selectedColor) {
          final newColor = selectedColor ?? Colors.black;
          selectedTextColor.value = newColor;
          htmlEditorApi?.setColorTextForeground(selectedTextColor.value);
        });
        break;
      case RichTextStyleType.textBackgroundColor:
        openMenuSelectColor(context, selectedTextBackgroundColor.value,
            onResetToDefault: () {
          selectedTextBackgroundColor.value = Colors.white;
          htmlEditorApi
              ?.setColorTextBackground(selectedTextBackgroundColor.value);
        }, onSelectColor: (selectedColor) {
          final newColor = selectedColor ?? Colors.white;
          selectedTextBackgroundColor.value = newColor;
          htmlEditorApi
              ?.setColorTextBackground(selectedTextBackgroundColor.value);
        });
        break;
      case RichTextStyleType.bold:
        await htmlEditorApi?.formatBold().then((value) {
          _selectTextStyleType(RichTextStyleType.bold);
        });
        break;
      case RichTextStyleType.italic:
        await htmlEditorApi?.formatItalic().then((value) {
          _selectTextStyleType(RichTextStyleType.italic);
        });
        break;
      case RichTextStyleType.underline:
        await htmlEditorApi?.formatUnderline().then((value) {
          _selectTextStyleType(RichTextStyleType.underline);
        });
        break;
      case RichTextStyleType.strikeThrough:
        await htmlEditorApi?.formatStrikeThrough().then((value) {
          _selectTextStyleType(RichTextStyleType.strikeThrough);
        });
        break;
      default:
        break;
    }
  }

  _selectTextStyleType(RichTextStyleType richTextStyleType) {
    if (listTextStyleApply.contains(richTextStyleType)) {
      listTextStyleApply.remove(richTextStyleType);
    } else {
      listTextStyleApply.add(richTextStyleType);
    }
  }

  bool isTextStyleTypeSelected(RichTextStyleType richTextStyleType) {
    return listTextStyleApply.contains(richTextStyleType);
  }

  void applyNewFontStyle(SafeFont? newFont) {
    final fontSelected = newFont ?? SafeFont.sansSerif;
    selectedFontName.value = fontSelected;
    htmlEditorApi?.setFont(selectedFontName.value);
  }

  void insertImage(InlineImage image, {double? maxWithEditor}) async {
    log('RichTextMobileTabletController::insertImage(): $image | maxWithEditor: $maxWithEditor');
    if (image.source == ImageSource.network) {
      htmlEditorApi?.insertImageLink(image.link!);
    } else {
      await htmlEditorApi?.moveCursorAtLastNode();
      htmlEditorApi?.insertHtml(image.base64Uri ?? '');
    }
  }

  void applyHeaderStyle(HeaderStyleType? newStyle) {
    final styleSelected = newStyle ?? HeaderStyleType.normal;
    htmlEditorApi?.formatHeader(styleSelected.styleValue);
  }

  void applyParagraphType(ParagraphType newParagraph) async {
    selectedParagraph.value = newParagraph;
    switch(newParagraph) {
      case ParagraphType.alignLeft:
        await htmlEditorApi?.formatAlignLeft();
        break;
      case ParagraphType.alignRight:
        await htmlEditorApi?.formatAlignRight();
        break;
      case ParagraphType.alignCenter:
        await htmlEditorApi?.formatAlignCenter();
        break;
      case ParagraphType.justify:
        await htmlEditorApi?.formatAlignJustify();
        break;
      case ParagraphType.indent:
        await htmlEditorApi?.formatIndent();
        break;
      case ParagraphType.outdent:
        await htmlEditorApi?.formatOutent();
        break;
    }
    menuParagraphController.hideMenu();
  }

  void applyOrderListType(OrderListType newOrderList) async {
    selectedOrderList.value = newOrderList;
    switch(newOrderList) {
      case OrderListType.bulletedList:
        await htmlEditorApi?.insertUnorderedList();
        break;
      case OrderListType.numberedList:
        await htmlEditorApi?.insertOrderedList();
        break;
    }
    menuOrderListController.hideMenu();
  }

  @override
  void onClose() {
    menuParagraphController.dispose();
    menuOrderListController.dispose();
    super.onClose();
  }
}
