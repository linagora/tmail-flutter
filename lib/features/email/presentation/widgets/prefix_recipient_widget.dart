
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';

class PrefixRecipientWidget extends StatelessWidget {
  final PrefixEmailAddress prefixEmailAddress;

  const PrefixRecipientWidget({super.key, required this.prefixEmailAddress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '${prefixEmailAddress.asName(context)}:',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.colorEmailAddressFull
        )
      ),
    );
  }
}