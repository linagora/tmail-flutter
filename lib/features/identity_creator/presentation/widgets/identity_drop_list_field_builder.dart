
import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

typedef OnSelectEmailAddressDropListAction = Function(EmailAddress? emailAddress);

class IdentityDropListFieldBuilder {

  final ImagePaths _imagePaths;
  final String _label;
  final EmailAddress? _emailAddressSelected;
  final List<EmailAddress> _listEmailAddress;

  OnSelectEmailAddressDropListAction? onSelectItemDropList;

  IdentityDropListFieldBuilder(
    this._imagePaths,
    this._label,
    this._emailAddressSelected,
    this._listEmailAddress,
  );

  void addOnSelectEmailAddressDropListAction(OnSelectEmailAddressDropListAction action) {
    onSelectItemDropList = action;
  }

  Widget build() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_label, style: const TextStyle(
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
                _emailAddressSelected?.email ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                maxLines: 1,
                overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
              )),
            ],
          ),
          items: _listEmailAddress.map((item) => DropdownMenuItem<EmailAddress>(
            value: item,
            child: Text(
              item.email ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
              maxLines: 1,
              overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
            ),
          )).toList(),
          value: _emailAddressSelected,
          onChanged: (newEmailAddress) => onSelectItemDropList?.call(newEmailAddress),
          icon: SvgPicture.asset(_imagePaths.icDropDown),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
          buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
              color: AppColor.colorInputBackgroundCreateMailbox),
          itemHeight: 44,
          buttonHeight: 44,
          selectedItemHighlightColor: Colors.black12,
          itemPadding: const EdgeInsets.symmetric(horizontal: 12),
          dropdownMaxHeight: 200,
          dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
          dropdownElevation: 4,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6,
        ),
      )
    ]);
  }
}