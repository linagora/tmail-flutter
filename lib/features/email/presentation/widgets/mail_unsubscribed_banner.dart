
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailUnsubscribedBanner extends StatelessWidget {
  final PresentationEmail? presentationEmail;
  final EmailUnsubscribe? emailUnsubscribe;

  const MailUnsubscribedBanner({
    super.key,
    required this.presentationEmail,
    this.emailUnsubscribe
  });

  @override
  Widget build(BuildContext context) {
    if (presentationEmail?.isSubscribed == true && emailUnsubscribe == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16, start: 20, end: 20),
        child: Text(
          AppLocalizations.of(context).mailUnsubscribedMessage(presentationEmail?.firstEmailAddressInFrom ?? ''),
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 15,
            color: AppColor.labelColor
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}