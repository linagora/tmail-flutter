import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/add_rule_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/count_name_of_rules_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/list_email_rules_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/no_rules_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/email_rule_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class EmailRulesView extends GetWidget<EmailRulesController>
    with AppLoaderMixin {
  const EmailRulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);

    return SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          controller.responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          controller.responsiveUtils,
        ),
        width: double.infinity,
        padding: isDesktop
            ? const EdgeInsetsDirectional.only(
                start: 30,
                end: 30,
                top: 22,
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SettingHeaderWidget(
                      menuItem: AccountMenuItem.emailRules,
                      textStyle: ThemeUtils.textStyleInter600().copyWith(
                        color: Colors.black.withValues(alpha: 0.9),
                      ),
                      padding: const EdgeInsetsDirectional.only(end: 16),
                    ),
                  ),
                  AddRuleButtonWidget(
                    imagePaths: controller.imagePaths,
                    margin: const EdgeInsetsDirectional.only(
                      start: 169,
                      top: 24,
                      end: 57,
                    ),
                    onAddRuleAction: controller.goToCreateNewRule,
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ] else ...[
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.emailRules,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
                isCenter: true,
                textAlign: TextAlign.center,
              ),
              Center(
                child: AddRuleButtonWidget(
                  imagePaths: controller.imagePaths,
                  margin: const EdgeInsetsDirectional.only(top: 24, bottom: 16),
                  minWidth: 230,
                  onAddRuleAction: controller.goToCreateNewRule,
                ),
              ),
            ],
            Obx(
              () => CountNameOfRulesWidget(
                countRules: controller.listEmailRule.length,
                margin: EdgeInsetsDirectional.only(
                  start: isDesktop ? 0 : 16,
                  top: 24,
                ),
              ),
            ),
            Obx(
              () => controller.isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: loadingWidget,
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(() {
              if (controller.listEmailRule.isEmpty) {
                if (controller.isLoading) {
                  return const SizedBox.shrink();
                } else {
                  return NoRulesWidget(
                    imagePaths: controller.imagePaths,
                    responsiveUtils: controller.responsiveUtils,
                    onAddRuleAction: controller.goToCreateNewRule,
                  );
                }
              } else {
                return Expanded(
                  child: ListEmailRulesWidget(
                    listEmailRule: controller.listEmailRule,
                    imagePaths: controller.imagePaths,
                    responsiveUtils: controller.responsiveUtils,
                    onDeleteEmailRuleAction: (rule) =>
                      controller.handleRuleFilterActionType(
                        context,
                        rule,
                        EmailRuleActionType.delete,
                      ),
                    onEditEmailRuleAction: (rule) =>
                      controller.handleRuleFilterActionType(
                        context,
                        rule,
                        EmailRuleActionType.edit,
                      ),
                    onMoreEmailRuleAction: (rule) =>
                      controller.openEditRuleMenuAction(
                        context,
                        rule,
                      ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
