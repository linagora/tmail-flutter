import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';
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
        border: Border.all(
            width: 1,
            color: AppColor.colorBorderListRuleFilter)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColor.colorBackgroundHeaderListRuleFilter,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
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
              const Divider(),
              Obx(() {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.listEmailRule.length,
                  primary: false,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final ruleWithId = controller.listEmailRule[index].copyWith(id: RuleId(id: Id(index.toString())));

                    return Obx(() {
                      return EmailRulesItemWidget(
                        imagePaths: controller.imagePaths,
                        responsiveUtils: controller.responsiveUtils,
                        rule: ruleWithId,
                        mailboxIds: controller.listMailboxIdsAppendIn.value,
                        editRuleAction: controller.editEmailRule,
                        deleteRuleAction: controller.deleteEmailRule,
                        openEditRuleMenuAction: controller.openEditRuleMenuAction,
                      );
                    });
                  },
                  separatorBuilder: (context, index) {
                    if (controller.listEmailRule.isNotEmpty) {
                      return const Divider();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }),
            ]),
      ),
    );
  }
}
