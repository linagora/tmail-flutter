import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_subject_styles.dart';

class EmailSubjectWidget extends StatelessWidget {

  final PresentationEmail presentationEmail;

  const EmailSubjectWidget({super.key, required this.presentationEmail});

  @override
  Widget build(BuildContext context) {
    if (presentationEmail.getEmailTitle().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EmailSubjectStyles.padding,
      child: Text(
        presentationEmail.getEmailTitle(),
        maxLines: EmailSubjectStyles.maxLines,
        style: const TextStyle(
          fontSize: EmailSubjectStyles.textSize,
          color: EmailSubjectStyles.textColor,
          fontWeight: EmailSubjectStyles.fontWeight
        )
      )
    );
  }
}
