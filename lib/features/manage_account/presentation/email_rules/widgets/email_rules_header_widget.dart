import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRulesHeaderWidget extends StatelessWidget {
  const EmailRulesHeaderWidget({
    Key? key,
    required this.createRule,
    required this.imagePaths,
    required this.responsiveUtils,
  }) : super(key: key);

  final VoidCallback createRule;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).emailRules,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).emailRulesSubtitle,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppColor.colorTextButtonHeaderThread)),
        const SizedBox(height: 24),
        _buildButtonAddNewRule(context),
      ]),
    );
  }

  Widget _buildButtonAddNewRule(BuildContext context) {
    if (!responsiveUtils.isMobile(context)) {
      return (ButtonBuilder(imagePaths.icAddNewRules)
            ..key(const Key('button_new_rule'))
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..maxWidth(130)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ))
            ..onPressActionClick(() => createRule.call())
            ..text(
              AppLocalizations.of(context).addNewRule,
              isVertical: false,
            ))
          .build();
    } else {
      return (ButtonBuilder(imagePaths.icAddNewRules)
            ..key(const Key('button_new_rule'))
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ))
            ..onPressActionClick(() => createRule.call())
            ..text(
              AppLocalizations.of(context).addNewRule,
              isVertical: false,
            ))
          .build();
    }
  }
}
