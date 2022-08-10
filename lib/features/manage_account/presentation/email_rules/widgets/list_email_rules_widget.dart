import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rule_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListEmailRulesWidget extends GetWidget<EmailRulesController> {
  const ListEmailRulesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const Divider(
              color: AppColor.lineItemListColor,
              height: 1,
              thickness: 0.2,
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.listEmailRule.length,
                  itemBuilder: (context, index) {
                    final rule = controller.listEmailRule[index];
                    return EmailRulesItemWidget(rule: rule);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    color: AppColor.lineItemListColor,
                    height: 1,
                    thickness: 0.2,
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
