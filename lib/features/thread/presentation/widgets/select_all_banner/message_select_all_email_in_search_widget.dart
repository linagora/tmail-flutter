
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MessageSelectAllEmailInSearchWidget extends StatelessWidget {

  final VoidCallback onClearSelection;

  const MessageSelectAllEmailInSearchWidget({
    super.key,
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
            text: AppLocalizations.of(context).allMailsInThisSearchAreSelected,
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