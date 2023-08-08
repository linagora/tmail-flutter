import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
        Text(AppLocalizations.of(context).emailRuleSettingExplanation,
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
      return Row(
        children: [
          TMailButtonWidget(
            key: const Key('new_rule_button'),
            text: AppLocalizations.of(context).addNewRule,
            icon: imagePaths.icAddNewRules,
            borderRadius: 10,
            backgroundColor: AppColor.colorTextButton,
            iconColor: Colors.white,
            minWidth: 130,
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
            iconSize: 20,
            textStyle: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            onTapActionCallback: createRule,
          ),
          const Spacer(),
        ],
      );
    } else {
      return TMailButtonWidget(
        key: const Key('new_rule_button'),
        text: AppLocalizations.of(context).addNewRule,
        icon: imagePaths.icAddNewRules,
        borderRadius: 10,
        backgroundColor: AppColor.colorTextButton,
        iconColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        iconSize: 20,
        textStyle: const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onTapActionCallback: createRule,
      );
    }
  }
}
