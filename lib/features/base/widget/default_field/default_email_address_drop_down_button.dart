import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef OnEmailAddressSelected = void Function(EmailAddress emailAddress);

class DefaultEmailAddressDropDownButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<EmailAddress> emailAddresses;
  final EmailAddress? emailAddressSelected;
  final OnEmailAddressSelected onEmailAddressSelected;
  final bool isEnabled;

  const DefaultEmailAddressDropDownButton({
    Key? key,
    required this.imagePaths,
    required this.emailAddresses,
    required this.onEmailAddressSelected,
    this.emailAddressSelected,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEnabled) {
      return DropdownButtonHideUnderline(
        child: PointerInterceptor(
          child: DropdownButton2<EmailAddress>(
            isExpanded: true,
            items: emailAddresses.map(_buildItemMenu).toList(),
            value: emailAddressSelected,
            customButton: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: AppColor.m3Neutral90,
                  width: 1,
                ),
                color: Colors.white,
              ),
              padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
              child: Row(children: [
                Expanded(
                  child: Text(
                    emailAddressSelected?.emailAddress ?? '',
                    style: ThemeUtils.textStyleBodyBody3(
                      color: AppColor.m3SurfaceBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SvgPicture.asset(imagePaths.icDropDown)
              ]),
            ),
            onChanged: (value) {
              if (value != null) {
                onEmailAddressSelected.call(value);
              }
            },
            dropdownStyleData: DropdownStyleData(
              maxHeight: 332,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: Colors.white,
                border: Border.all(color: AppColor.m3Tertiary60),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 24)
                ],
              ),
              padding: const EdgeInsets.all(12),
              elevation: 0,
              offset: const Offset(0.0, -3.0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all<double>(6),
                thumbVisibility: WidgetStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: AppColor.m3Neutral90,
            width: 1,
          ),
          color: AppColor.lightGrayF4F4F4,
        ),
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          emailAddressSelected?.emailAddress ?? '',
          style: ThemeUtils.textStyleBodyBody3(
            color: AppColor.m3SurfaceBackground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  DropdownMenuItem<EmailAddress> _buildItemMenu(EmailAddress emailAddress) {
    return DropdownMenuItem<EmailAddress>(
      value: emailAddress,
      enabled: emailAddress != emailAddressSelected,
      child: PointerInterceptor(
        child: Row(
          children: [
            Expanded(
              child: Text(
                emailAddress.emailAddress,
                style: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 15,
                  height: 20 / 15,
                  letterSpacing: -0.15,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (emailAddress == emailAddressSelected)
              SvgPicture.asset(
                imagePaths.icChecked,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
          ],
        ),
      ),
    );
  }
}
