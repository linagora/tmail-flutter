import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';

class EmailRulesItemWidget extends GetWidget<EmailRulesController> {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  EmailRulesItemWidget({
    Key? key,
    required this.rule,
  }) : super(key: key);

  final TMailRule rule;

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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        const Spacer(),
        if (!_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icEditRule,
                fit: BoxFit.fill,
              ),
              onTap: () {
                controller.editEmailRule(rule);
              }),
        if (!_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icDeleteRule,
                fit: BoxFit.fill,
              ),
              onTap: () {
                controller.deleteEmailRule(rule);
              }),
        if (_responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icOpenEditRule,
                fit: BoxFit.fill,
              ),
              iconPadding: const EdgeInsets.all(0),
              onTap: () {
                controller.openEditRuleMenuAction(context, rule);
              }),
      ]),
    );
  }
}
