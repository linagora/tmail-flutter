
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnOpenEmailAddressDetailAction = Function(BuildContext context, EmailAddress emailAddress);

class EmailSenderBuilder extends StatelessWidget {

  final EmailAddress emailAddress;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final bool showSenderEmail;

  const EmailSenderBuilder({
    super.key,
    required this.emailAddress,
    this.openEmailAddressDetailAction,
    this.showSenderEmail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emailAddress.displayName.isNotEmpty)
          MaterialTextButton(
            label: emailAddress.displayName,
            onTap: () => openEmailAddressDetailAction?.call(context, emailAddress),
            onLongPress: () {
              AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress);
            },
            borderRadius: 8,
            padding: EdgeInsets.zero,
            customStyle: ThemeUtils.textStyleHeadingHeadingSmall(
              color: Colors.black,
            ),
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap
          ),
        if (showSenderEmail)
          MaterialTextButton(
            label: '<${emailAddress.emailAddress}>',
            onTap: () => openEmailAddressDetailAction?.call(context, emailAddress),
            onLongPress: () {
              AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress);
            },
            borderRadius: 8,
            padding: EdgeInsets.zero,
            customStyle: ThemeUtils.textStyleBodyBody1(
              color: AppColor.steelGray400,
            ),
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap
          )
      ]
    );
  }
}