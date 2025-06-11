
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
    return Transform.translate(
      offset: const Offset(-2, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
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
                padding: const EdgeInsets.all(2),
                customStyle: ThemeUtils.textStyleHeadingH6(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ).copyWith(height: 1, letterSpacing: -0.2),
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
                padding: const EdgeInsets.all(2),
                customStyle: ThemeUtils.textStyleBodyBody1(
                  color: AppColor.gray6D7885,
                ).copyWith(
                  fontSize: 17,
                  height: 1,
                  letterSpacing: -0.17,
                ),
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap
              )
          ]
        ),
      ),
    );
  }
}