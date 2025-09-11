import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRulesItemWidget extends StatelessWidget {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _emailRuleController = Get.find<EmailRulesController>();

  final TMailRule rule;

  EmailRulesItemWidget({
    Key? key,
    required this.rule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        top: 15,
        bottom: 15,
        start: _responsiveUtils.isMobile(context) ? 16 : 24,
        end: _responsiveUtils.isMobile(context) ? 0 : 24
      ),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(rule.name,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        const Spacer(),
        if (_responsiveUtils.isMobile(context))
          buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icOpenEditRule,
              fit: BoxFit.fill,
            ),
            iconPadding: EdgeInsets.zero,
            onTap: () =>
                _emailRuleController.openEditRuleMenuAction(context, rule),
          )
        else
          ...[
            TMailButtonWidget.fromIcon(
              icon: _imagePaths.icCompose,
              iconColor: AppColor.primaryColor,
              iconSize: 24,
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.transparent,
              tooltipMessage: AppLocalizations.of(context).editRule,
              margin: const EdgeInsetsDirectional.only(end: 5),
              onTapActionCallback: () =>
                  _emailRuleController.editEmailRule(context, rule),
            ),
            TMailButtonWidget.fromIcon(
              icon: _imagePaths.icDeleteRule,
              iconColor: AppColor.primaryColor,
              iconSize: 24,
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.transparent,
              tooltipMessage: AppLocalizations.of(context).deleteRule,
              onTapActionCallback: () =>
                  _emailRuleController.deleteEmailRule(context, rule),
            ),
          ]
      ]),
    );
  }
}
