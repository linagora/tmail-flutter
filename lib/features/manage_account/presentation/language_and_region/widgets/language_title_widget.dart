
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LanguageTitleWidget extends StatelessWidget {
  const LanguageTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).language,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColor.colorContentEmail
      )
    );
  }
}
