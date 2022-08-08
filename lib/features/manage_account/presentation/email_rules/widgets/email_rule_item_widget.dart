import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';

class EmailRulesItemWidget extends GetWidget<EmailRulesController> {
  final _imagePaths = Get.find<ImagePaths>();

  EmailRulesItemWidget({
    Key? key,
    required this.editRule,
    required this.rule,
    required this.deleteRule,
  }) : super(key: key);

  final void Function(TMailRule) editRule;
  final TMailRule rule;
  final void Function(TMailRule) deleteRule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(rule.name,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        const Spacer(),
        buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icEditRule,
              fit: BoxFit.fill,
            ),
            onTap: () {
              editRule.call(rule);
            }),
        buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icDeleteAttachment,
              fit: BoxFit.fill,
            ),
            onTap: () {
              deleteRule.call(rule);
            }),
      ]),
    );
  }
}
