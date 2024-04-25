
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MessageSelectAllEmailInMailboxWidget extends StatelessWidget {

  final int totalEmails;
  final String folderName;
  final VoidCallback onClearSelection;

  const MessageSelectAllEmailInMailboxWidget({
    super.key,
    required this.totalEmails,
    required this.folderName,
    required this.onClearSelection
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.black,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: AppLocalizations.of(context).all,
          ),
          TextSpan(
            text: ' $totalEmails ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context).mailsInMailboxAreSelected(folderName),
          ),
          TextSpan(
            text: AppLocalizations.of(context).clearSelection,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            recognizer: TapGestureRecognizer()..onTap = onClearSelection
          )
        ]
      )
    );
  }
}