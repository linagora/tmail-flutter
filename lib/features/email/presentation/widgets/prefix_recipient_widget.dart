
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';

class PrefixRecipientWidget extends StatelessWidget {
  final PrefixEmailAddress prefixEmailAddress;
  final ResponsiveUtils responsiveUtils;

  const PrefixRecipientWidget({
    super.key,
    required this.prefixEmailAddress,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsiveUtils.isMobile(context) ? 4 : 5.5),
      child: Text(
        '${prefixEmailAddress.asName(context)}:',
        style: ThemeUtils.textStyleBodyBody1(
          color: AppColor.steelGray400,
          fontWeight: FontWeight.w400,
        ).copyWith(
          fontSize: responsiveUtils.isMobile(context) ? 14 : 17,
          height: 1,
          letterSpacing: responsiveUtils.isMobile(context) ? -0.14 : -0.17
        ),
      ),
    );
  }
}