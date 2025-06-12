
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart' as rich_text_composer;
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
  final Color colorButton;
  final String tooltip;
  final double? dropdownWidth;
  final double? dropdownMaxHeight;
  final String? hintText;

  const DropDownButtonWidget({
    Key? key,
    required this.items,
    this.itemSelected,
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
    this.dropdownMaxHeight,
    this.colorButton = Colors.white,
    this.tooltip = '',
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

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
                            SvgPicture.asset(imagePaths.icChecked,
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
                      width: 1,
                    ),
                    color: colorButton,
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  child: Row(children: [
                    Expanded(child: Text(
                      _getTextItemDropdown(context, item: itemSelected),
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: itemSelected != null ? Colors.black.withOpacity(opacity) : AppColor.textFieldHintColor),
                      maxLines: 1,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                    )),
                    iconArrowDown ?? SvgPicture.asset(imagePaths.icDropDown)
                  ]),
                ),
              )
            : null,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: heightItem,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusButton),
              border: Border.all(
                color: AppColor.colorInputBorderCreateMailbox,
                width: 1,
              ),
              color: colorButton,
            )
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: dropdownMaxHeight ?? 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusButton),
              color: Colors.white,
            ),
            width: dropdownWidth,
            elevation: 4,
            offset: const Offset(0.0, -8.0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          iconStyleData: IconStyleData(icon: iconArrowDown ?? SvgPicture.asset(imagePaths.icDropDown)),
          menuItemStyleData: MenuItemStyleData(
            height: heightItem,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            overlayColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) => supportSelectionIcon ? Colors.white : Colors.black12)
          ),
          onMenuStateChange: onMenuStateChange,
        ),
      ),
    );
  }

  String _getTextItemDropdown(BuildContext context, {required T? item}) {
    final appLocalizations = AppLocalizations.of(context);

    if (item is Identity) {
      return item.name ?? '';
    }
    if (item is FontNameType) {
      return item.title;
    }
    if (item is rich_text_composer.SafeFont) {
      return item.name;
    }
    if (item is rule_condition.Field) {
      return item.getTitle(appLocalizations);
    }
    if (item is rule_condition.Comparator) {
      return item.getTitle(appLocalizations);
    }
    if (item is EmailRuleFilterAction) {
      return item.getTitle(appLocalizations);
    }
    if (item is ConditionCombiner) {
      return item.getTitle(appLocalizations);
    }
    return hintText ?? '';
  }
}