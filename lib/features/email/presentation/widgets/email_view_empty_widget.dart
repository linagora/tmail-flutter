import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_empty_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailViewEmptyWidget extends StatelessWidget {

  const EmailViewEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).no_mail_selected,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: EmailViewEmptyStyles.textSize,
          color: EmailViewEmptyStyles.textColor,
          fontWeight: EmailViewEmptyStyles.fontWeight
        )
      ),
    );
  }
}
