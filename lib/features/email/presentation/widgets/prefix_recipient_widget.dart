
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';

class PrefixRecipientWidget extends StatelessWidget {
  final PrefixEmailAddress prefixEmailAddress;

  const PrefixRecipientWidget({super.key, required this.prefixEmailAddress});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${prefixEmailAddress.asName(context)}:',
      style: ThemeUtils.textStyleBodyBody1(color: AppColor.steelGray400),
    );
  }
}