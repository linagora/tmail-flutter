
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';

class DropDownMenuHeaderStyleWidget extends StatelessWidget {

  final Widget icon;
  final List<HeaderStyleType> items;
  final Function(HeaderStyleType?)? onChanged;
  final Function(bool)? onMenuStateChange;
  final double heightItem;
  final double dropdownWidth;

  const DropDownMenuHeaderStyleWidget({
    Key? key,
    required this.icon,
    required this.items,
    this.onChanged,
    this.onMenuStateChange,
    this.heightItem = 44,
    this.dropdownWidth = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<HeaderStyleType>(
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<HeaderStyleType>(
                    value: item,
                    child: PointerInterceptor(
                      child: Container(
                        color: Colors.transparent,
                        height: heightItem,
                        alignment: Alignment.centerLeft,
                        child: _buildItemDropdown(item),
                      ),
                    ),
                  ))
              .toList(),
          customButton: icon,
          onChanged: onChanged,
          onMenuStateChange: onMenuStateChange,
          buttonStyleData: ButtonStyleData(height: heightItem),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: dropdownWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white),
            elevation: 4,
            offset: const Offset(0.0, -8.0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            )
          ),
          menuItemStyleData: MenuItemStyleData(
            height: heightItem,
            padding: const EdgeInsets.symmetric(horizontal: 12)
          )
        ),
      ),
    );
  }

  Widget _buildItemDropdown(HeaderStyleType headerStyle) {
    switch(headerStyle) {
      case HeaderStyleType.blockquote:
        return Container(
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(color: AppColor.colorStyleBlockQuote,
                    width: 5.0))),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildHeaderStyle(
                headerStyle.styleName,
                headerStyle.textSize,
                headerStyle.fontWeight));
      case HeaderStyleType.code:
        return Container(
            width: dropdownWidth,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColor.colorBorderStyleCode, width: 1.0),
                color: AppColor.colorBackgroundStyleCode),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: _buildHeaderStyle(
                headerStyle.styleName,
                headerStyle.textSize,
                headerStyle.fontWeight));
      default:
        return _buildHeaderStyle(
            headerStyle.styleName,
            headerStyle.textSize,
            headerStyle.fontWeight);
    }
  }

  Widget _buildHeaderStyle(String name, double size, FontWeight fontWeight) {
    return Text(name,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: size,
          fontWeight: fontWeight,
          color: Colors.black,
        ),
        maxLines: 1,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow);
  }
}