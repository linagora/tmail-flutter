
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class IdentityFieldNoEditableBuilder extends StatelessWidget {

  final String _label;
  final EmailAddress? _emailAddressSelected;

  const IdentityFieldNoEditableBuilder(
    this._label,
    this._emailAddressSelected,
    {super.key}
  );

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
      Container(
        height: 44,
        alignment: Alignment.centerLeft,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
          color: AppColor.colorInputBackgroundCreateMailbox),
        child: Text(
          _emailAddressSelected?.email ?? '',
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColor.colorInputBorderCreateMailbox),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap
        )
      ),
    ]);
  }
}