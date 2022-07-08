
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LanguageAndRegionHeaderWidget extends StatelessWidget {

  const LanguageAndRegionHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).languageAndRegion,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).languageAndRegionSubtitle,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppColor.colorTextButtonHeaderThread))
      ]);
  }
}