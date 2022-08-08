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

  final Function() createRule;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 24,
          ),
          child: Text(AppLocalizations.of(context).headerNameOfRules,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColor.colorTextButtonHeaderThread)),
        ),
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
