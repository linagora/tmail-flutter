import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_subject_styles.dart';

class EmailSubjectWidget extends StatelessWidget {

  final PresentationEmail presentationEmail;
  final bool isMobileResponsive;

  const EmailSubjectWidget({
    super.key,
    required this.presentationEmail,
    this.isMobileResponsive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (presentationEmail.getEmailTitle().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: isMobileResponsive
          ? EmailSubjectStyles.mobilePadding
          : EmailSubjectStyles.padding,
      child: Text(
        presentationEmail.getEmailTitle(),
        style: EmailSubjectStyles.textStyle,
        maxLines: EmailSubjectStyles.maxLines,
      )
    );
  }
}
