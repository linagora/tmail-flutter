
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:enough_html_editor/enough_html_editor.dart' as enough_html_editor;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';

class DropDownButtonWidget<T> extends StatelessWidget {

  final List<T> items;
  final T? itemSelected;
  final Function(T?)? onChanged;
  final Function(bool)? onMenuStateChange;
  final bool supportHint;
  final bool supportSelectionIcon;
  final double heightItem;
  final double sizeIconChecked;
  final double radiusButton;
  final double opacity;
  final Widget? iconArrowDown;
  final Color? colorButton;
  final String tooltip;
  final double? dropdownWidth;

  const DropDownButtonWidget({
    Key? key,
    required this.items,
    required this.itemSelected,
    this.onChanged,
    this.onMenuStateChange,
    this.supportHint = false,
    this.supportSelectionIcon = false,
    this.heightItem = 44,
    this.sizeIconChecked = 20,
    this.radiusButton = 10,
    this.opacity = 1.0,
    this.iconArrowDown,
    this.dropdownWidth,
    this.colorButton = Colors.white,
    this.tooltip = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<T>(
          isExpanded: true,
          hint: supportHint
              ? Row(children: [
                  Expanded(child: Text(
                    _getTextItemDropdown(context, item: itemSelected),
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black.withOpacity(opacity)),
                    maxLines: 1,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                  )),
                ])
              : null,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: PointerInterceptor(
                      child: Container(
                        color: Colors.transparent,
                        height: heightItem,
                        child: Row(children: [
                          Expanded(child: Text(_getTextItemDropdown(context, item: item),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                            maxLines: 1,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                          )),
                          if (supportSelectionIcon && item == itemSelected)
                            SvgPicture.asset(_imagePaths.icChecked,
                              width: sizeIconChecked,
                              height: sizeIconChecked,
                              fit: BoxFit.fill)
                        ]),
                      ),
                    ),
                  ))
              .toList(),
          value: itemSelected,
          customButton: supportSelectionIcon
            ? Tooltip(
                message: tooltip,
                child: Container(
                  height: heightItem,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radiusButton),
                    border: Border.all(
                      color: AppColor.colorInputBorderCreateMailbox,
                      width: 0.5,
                    ),
                    color: colorButton ?? AppColor.colorInputBackgroundCreateMailbox,
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  child: Row(children: [
                    Expanded(child: Text(
                      _getTextItemDropdown(context, item: itemSelected),
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black.withOpacity(opacity)),
                      maxLines: 1,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                    )),
                    iconArrowDown ?? SvgPicture.asset(_imagePaths.icDropDown)
                  ]),
                ),
              )
            : null,
          onChanged: onChanged,
          icon: iconArrowDown ?? SvgPicture.asset(_imagePaths.icDropDown),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusButton),
            border: Border.all(
              color: AppColor.colorInputBorderCreateMailbox,
              width: 0.5,
            ),
            color: colorButton ?? AppColor.colorInputBackgroundCreateMailbox,
          ),
          itemHeight: heightItem,
          buttonHeight: heightItem,
          selectedItemHighlightColor: supportSelectionIcon
              ? Colors.white
              : Colors.black12,
          itemPadding: const EdgeInsets.symmetric(horizontal: 12),
          dropdownMaxHeight: 200,
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusButton),
            color: Colors.white,
          ),
          offset: const Offset(0.0, -8.0),
          dropdownElevation: 4,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6,
          onMenuStateChange: onMenuStateChange,
          dropdownWidth: dropdownWidth,
        ),
      ),
    );
  }

  String _getTextItemDropdown(BuildContext context, {required T? item}) {
    if (item is Identity) {
      return item.name ?? '';
    }
    if (item is Locale) {
      return item.getLanguageName(context);
    }
    if (item is FontNameType) {
      return item.fontFamily;
    }
    if (item is enough_html_editor.SafeFont) {
      return item.name;
    }
    return '';
  }
}