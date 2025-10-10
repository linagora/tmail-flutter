import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';

class PrefixRecipientWidget extends StatelessWidget {
  final PrefixEmailAddress prefixEmailAddress;
  final EdgeInsetsGeometry? padding;
  final bool isMobileResponsive;

  const PrefixRecipientWidget({
    super.key,
    required this.prefixEmailAddress,
    this.isMobileResponsive = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Text(
      '${prefixEmailAddress.asName(context)}:',
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 14,
        height: 1,
        letterSpacing: -0.14,
        color: isMobileResponsive ? AppColor.gray6D7885 : AppColor.gray9AA7B6,
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}