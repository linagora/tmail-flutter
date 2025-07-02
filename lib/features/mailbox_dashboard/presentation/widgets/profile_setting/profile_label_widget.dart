import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/email_address_with_copy_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/copy_subaddress_widget.dart';

class ProfileLabelWidget extends StatelessWidget {
  final String label;
  final String copyLabelIcon;
  final OnCopyButtonAction onCopyButtonAction;

  const ProfileLabelWidget({
    super.key,
    required this.label,
    required this.copyLabelIcon,
    required this.onCopyButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: EmailAddressWithCopyWidget(
        label: label,
        copyLabelIcon: copyLabelIcon,
        onCopyButtonAction: onCopyButtonAction,
      ),
    );
  }
}
