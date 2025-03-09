import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
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
      decoration: const BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (responsiveUtils.isWebDesktop(context))
            const SettingHeaderWidget(menuItem: AccountMenuItem.emailRules)
          else
            const SettingExplanationWidget(menuItem: AccountMenuItem.emailRules),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildButtonAddNewRule(context),
          ),
        ],
      ),
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
