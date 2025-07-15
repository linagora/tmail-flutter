import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';

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
      padding: EdgeInsets.only(
        top: 15,
        bottom: 15,
        left: _responsiveUtils.isMobile(context) ? 16 : 24,
        right: _responsiveUtils.isMobile(context) ? 0 : 24
      ),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(rule.name,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        const Spacer(),
        if (!_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icEditRule,
                fit: BoxFit.fill,
                colorFilter: AppColor.primaryColor.asFilter(),
              ),
              onTap: () {
                _emailRuleController.editEmailRule(context, rule);
              }),
        if (!_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icDeleteRule,
                fit: BoxFit.fill,
              ),
              onTap: () {
                _emailRuleController.deleteEmailRule(context, rule);
              }),
        if (_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icOpenEditRule,
                fit: BoxFit.fill,
              ),
              iconPadding: const EdgeInsets.all(0),
              onTap: () {
                _emailRuleController.openEditRuleMenuAction(context, rule);
              }),
      ]),
    );
  }
}
