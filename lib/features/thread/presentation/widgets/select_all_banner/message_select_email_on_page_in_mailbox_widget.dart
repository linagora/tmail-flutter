
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MessageSelectEmailOnPageInMailboxWidget extends StatelessWidget {

  final int limitEmailsInPage;
  final int totalEmails;
  final String folderName;
  final VoidCallback onSelectAllEmailAction;

  const MessageSelectEmailOnPageInMailboxWidget({
    super.key,
    required this.limitEmailsInPage,
    required this.totalEmails,
    required this.folderName,
    required this.onSelectAllEmailAction,
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
            text: '${AppLocalizations.of(context).mailsOnThisPageAreSelected(limitEmailsInPage)} ',
          ),
          TextSpan(
            text: AppLocalizations.of(context).selectAllMailInMailbox(
              totalEmails,
              folderName,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            recognizer: TapGestureRecognizer()..onTap = onSelectAllEmailAction
          ),
        ],
      ),
    );
  }
}