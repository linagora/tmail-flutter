
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';

typedef OnSelectEmailAddressDropListAction = Function(EmailAddress? emailAddress);

class IdentityDropListFieldBuilder extends StatelessWidget {

  final ImagePaths _imagePaths;
  final String _label;
  final EmailAddress? _emailAddressSelected;
  final List<EmailAddress> _listEmailAddress;
  final OnSelectEmailAddressDropListAction? onSelectItemDropList;

  const IdentityDropListFieldBuilder(
    this._imagePaths,
    this._label,
    this._emailAddressSelected,
    this._listEmailAddress, {
    super.key,
    this.onSelectItemDropList
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _label,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      DropdownButtonHideUnderline(
        child: DropdownButton2<EmailAddress>(
          isExpanded: true,
          hint: Row(
            children: [
              Expanded(child: Text(
                '',
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
              )),
            ],
          ),
          items: _listEmailAddress.map((item) => DropdownMenuItem<EmailAddress>(
            value: item,
            child: Text(
              item.emailAddress,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
              maxLines: 1,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
            ),
          )).toList(),
          value: _emailAddressSelected,
          onChanged: onSelectItemDropList,
          buttonStyleData: ButtonStyleData(
            height: 44,
            padding: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
              color: AppColor.colorInputBackgroundCreateMailbox),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
            elevation: 4,
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset(_imagePaths.icDropDown),
            iconSize: 14,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      )
    ]);
  }
}