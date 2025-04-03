

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ViewEntireMessageWithMessageClippedWidget extends StatelessWidget {

  final String buttonActionName;
  final VoidCallback onViewEntireMessageAction;
  final double? topPadding;

  const ViewEntireMessageWithMessageClippedWidget({
    super.key,
    required this.buttonActionName,
    required this.onViewEntireMessageAction,
    this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topPadding != null)
          SizedBox(height: topPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context).messageClipped,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.steelGray400,
            ),
          ),
        ),
        TMailButtonWidget.fromText(
          text: buttonActionName,
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColor.primaryColor,
            fontSize: 14,
          ),
          margin: const EdgeInsetsDirectional.only(
            start: 8,
            end: 8,
            bottom: 24,
          ),
          backgroundColor: Colors.transparent,
          onTapActionCallback: onViewEntireMessageAction,
        ),
      ],
    );
  }
}
