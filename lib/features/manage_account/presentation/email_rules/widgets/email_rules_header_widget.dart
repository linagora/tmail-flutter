import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRulesHeaderWidget extends GetWidget<EmailRulesController> {
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
    final buttonAddNewRule = Row(children: [
      if (!responsiveUtils.isMobile(context))
        (ButtonBuilder(imagePaths.icAddNewRules)
              ..key(const Key('button_new_rule'))
              ..decoration(BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.colorTextButton))
              ..paddingIcon(const EdgeInsets.only(right: 8))
              ..iconColor(Colors.white)
              ..maxWidth(170)
              ..size(20)
              ..radiusSplash(10)
              ..padding(const EdgeInsets.symmetric(vertical: 12))
              ..textStyle(const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ))
              ..onPressActionClick(() => controller.goToCreateNewRule())
              ..text(
                AppLocalizations.of(context).addNewRule,
                isVertical: false,
              ))
            .build()
    ]);
    return Container(
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
        buttonAddNewRule,
      ]),
    );
  }
}
