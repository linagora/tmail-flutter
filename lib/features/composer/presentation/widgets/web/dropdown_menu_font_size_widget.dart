
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/key_values/composer_key_values.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/dropdown_menu_font_size_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/dropdown_button_font_size_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/item_menu_font_size_widget.dart';

class DropdownMenuFontSizeWidget extends StatelessWidget {

  final Function(int?)? onChanged;
  final int selectedFontSize;

  const DropdownMenuFontSizeWidget({
    Key? key,
    required this.selectedFontSize,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<int>(
        value: selectedFontSize,
        items: RichTextWebController.fontSizeList.map((value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Semantics(
              excludeSemantics: true,
              identifier: ComposerKeyValues.richtextFontSizeOption,
              child: ItemMenuFontSizeWidget(
                value: value,
                selectedValue: selectedFontSize
              ),
            )
          );
        }).toList(),
        customButton: DropdownButtonFontSizeWidget(value: selectedFontSize),
        onChanged: onChanged,
        dropdownStyleData: const DropdownStyleData(
          maxHeight: DropdownMenuFontSizeWidgetStyle.menuMaxHeight,
          width: DropdownMenuFontSizeWidgetStyle.menuWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(DropdownMenuFontSizeWidgetStyle.menuRadius)),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: DropdownMenuFontSizeWidgetStyle.menuItemHeight,
          padding: DropdownMenuFontSizeWidgetStyle.menuItemPadding,
        )
      ),
    );
  }
}