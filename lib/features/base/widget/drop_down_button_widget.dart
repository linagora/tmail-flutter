
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';

class DropDownButtonWidget<T> extends StatelessWidget {

  final List<T> items;
  final T? itemSelected;
  final Function(T?)? onChanged;
  final bool supportHint;
  final bool supportSelectionIcon;

  const DropDownButtonWidget({
    Key? key,
    required this.items,
    required this.itemSelected,
    this.onChanged,
    this.supportHint = false,
    this.supportSelectionIcon = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        hint: supportHint
            ? Row(children: [
                Expanded(child: Text(
                  _getTextItemDropdown(context, item: itemSelected),
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                )),
              ])
            : null,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Row(children: [
                    Expanded(child: Text(_getTextItemDropdown(context, item: item),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      maxLines: 1,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                    )),
                    if (supportSelectionIcon && item == itemSelected)
                      SvgPicture.asset(_imagePaths.icChecked,
                        width: 20,
                        height: 20,
                        fit: BoxFit.fill)
                  ]),
                ))
            .toList(),
        value: itemSelected,
        customButton: supportSelectionIcon
          ? Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColor.colorInputBorderCreateMailbox,
                  width: 0.5,
                ),
                color: AppColor.colorInputBackgroundCreateMailbox,
              ),
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: Row(children: [
                Expanded(child: Text(
                  _getTextItemDropdown(context, item: itemSelected),
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                )),
                SvgPicture.asset(_imagePaths.icDropDown)
              ]),
            )
          : null,
        onChanged: onChanged,
        icon: SvgPicture.asset(_imagePaths.icDropDown),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
        buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColor.colorInputBorderCreateMailbox,
            width: 0.5,
          ),
          color: AppColor.colorInputBackgroundCreateMailbox,
        ),
        itemHeight: 44,
        buttonHeight: 44,
        selectedItemHighlightColor: supportSelectionIcon
            ? Colors.white
            : Colors.black12,
        itemPadding: const EdgeInsets.symmetric(horizontal: 12),
        dropdownMaxHeight: 200,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        offset: const Offset(0.0, -8.0),
        dropdownElevation: 4,
        scrollbarRadius: const Radius.circular(40),
        scrollbarThickness: 6,
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
    return '';
  }
}