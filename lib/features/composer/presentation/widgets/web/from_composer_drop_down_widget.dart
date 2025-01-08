import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/from_composer_drop_down_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangeIdentity = void Function(Identity? identity);

class FromComposerDropDownWidget extends StatelessWidget {

  final List<Identity> items;
  final GlobalKey<DropdownButton2State>? dropdownKey;
  final Identity? itemSelected;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final OnChangeIdentity? onChangeIdentity;
  final ImagePaths imagePaths;

  const FromComposerDropDownWidget({
    super.key,
    required this.items,
    required this.dropdownKey,
    required this.imagePaths,
    this.itemSelected,
    this.padding,
    this.margin,
    this.onChangeIdentity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.colorLineComposer,
            width: 1,
          )
        )
      ),
      padding: padding,
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: FromComposerDropDownWidgetStyle.prefixPadding,
            child: Text(
              '${PrefixEmailAddress.from.asName(context)}:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.m3Tertiary,
              ),
            ),
          ),
          const SizedBox(width: FromComposerDropDownWidgetStyle.space),
          Padding(
            padding: FromComposerDropDownWidgetStyle.dropdownButtonPadding,
            child: DropdownButtonHideUnderline(
              child: PointerInterceptor(
                child: DropdownButton2<Identity>(
                  key: dropdownKey,
                  isExpanded: false,
                  items: items.map((item) => DropdownMenuItem<Identity>(
                    value: item,
                    child: PointerInterceptor(
                      child: Container(
                        color: Colors.transparent,
                        padding: FromComposerDropDownWidgetStyle.dropdownItemPadding,
                        child: Row(
                          children: [
                            Container(
                              width: FromComposerDropDownWidgetStyle.avatarSize,
                              height: FromComposerDropDownWidgetStyle.avatarSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.avatarColor,
                                border: Border.all(
                                  color: AppColor.colorShadowBgContentEmail,
                                  width: FromComposerDropDownWidgetStyle.avatarBorderWidth
                                )
                              ),
                              child: Text(
                                item.name!.isNotEmpty
                                  ? item.name!.firstLetterToUpperCase
                                  : item.email!.firstLetterToUpperCase,
                                style: FromComposerDropDownWidgetStyle.avatarTextStyle,
                              ),
                            ),
                            const SizedBox(width: FromComposerDropDownWidgetStyle.dropdownItemSpace),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (item.name!.isNotEmpty)
                                    Text(
                                      item.name!,
                                      maxLines: 1,
                                      softWrap: CommonTextStyle.defaultSoftWrap,
                                      overflow: CommonTextStyle.defaultTextOverFlow,
                                      style: FromComposerDropDownWidgetStyle.dropdownItemTitleTextStyle,
                                    ),
                                  if (item.email!.isNotEmpty)
                                    Text(
                                      item.email!,
                                      maxLines: 1,
                                      softWrap: CommonTextStyle.defaultSoftWrap,
                                      overflow: CommonTextStyle.defaultTextOverFlow,
                                      style: FromComposerDropDownWidgetStyle.dropdownItemSubTitleTextStyle,
                                    )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                  value: itemSelected,
                  buttonStyleData: FromComposerDropDownWidgetStyle.buttonStyleData,
                  dropdownSearchData: DropdownSearchData(
                    searchInnerWidget: Container(
                      padding: FromComposerDropDownWidgetStyle.dropdownTopBarPadding,
                      child: Text(
                        AppLocalizations.of(context).yourIdentities,
                        style: FromComposerDropDownWidgetStyle.dropdownTitleTextStyle,
                      ),
                    ),
                    searchInnerWidgetHeight: FromComposerDropDownWidgetStyle.dropdownTopBarHeight,
                  ),
                  dropdownStyleData: FromComposerDropDownWidgetStyle.dropdownStyleData,
                  iconStyleData: IconStyleData(
                    icon: SvgPicture.asset(imagePaths.icDropDown),
                  ),
                  menuItemStyleData: FromComposerDropDownWidgetStyle.menuIemStyleData,
                  customButton: Tooltip(
                    message: itemSelected != null ? itemSelected!.email : '',
                    child: Container(
                      height: FromComposerDropDownWidgetStyle.buttonHeight,
                      width: FromComposerDropDownWidgetStyle.buttonWidth,
                      padding: FromComposerDropDownWidgetStyle.buttonPadding,
                      decoration: FromComposerDropDownWidgetStyle.buttonDecoration,
                      child: Row(
                        children: [
                          if (itemSelected != null)
                            Expanded(
                              child: RichText(
                                maxLines: 1,
                                softWrap: CommonTextStyle.defaultSoftWrap,
                                overflow: CommonTextStyle.defaultTextOverFlow,
                                text: TextSpan(
                                  children: [
                                    if (itemSelected!.name!.isNotEmpty)
                                      TextSpan(
                                        text: '${itemSelected!.name} ',
                                        style: FromComposerDropDownWidgetStyle.dropdownButtonTitleTextStyle,
                                      ),
                                    TextSpan(
                                      text: '(${itemSelected!.email})',
                                      style: itemSelected!.name!.isNotEmpty
                                        ? FromComposerDropDownWidgetStyle.dropdownButtonSubTitleTextStyle
                                        : FromComposerDropDownWidgetStyle.dropdownButtonTitleTextStyle
                                    )
                                  ]
                                ),
                              )
                            )
                          else
                            const SizedBox.shrink(),
                          SvgPicture.asset(imagePaths.icDropDown)
                        ],
                      ),
                    ),
                  ),
                  onChanged: onChangeIdentity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}