import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/select_rule_action_field_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_list_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_title_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterCreatorView extends GetWidget<RulesFilterCreatorController> {

  @override
  final controller = Get.find<RulesFilterCreatorController>();

  RuleFilterCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsiveUtil = controller.responsiveUtils;
    final isMobile = responsiveUtil.isMobile(context);
    final currentScreenHeight = responsiveUtil.getSizeScreenHeight(context);
    final currentScreenWidth = responsiveUtil.getSizeScreenWidth(context);

    Widget bodyWidget = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isMobile
          ? null
          : const BorderRadius.all(Radius.circular(16)),
        boxShadow: isMobile
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 2,
              ),
            ],
        ),
      width: isMobile
        ? double.infinity :
          math.min(
            currentScreenWidth,
            612,
          ),
      constraints: BoxConstraints(
        maxHeight: isMobile
          ? double.infinity
          : math.min(
            currentScreenHeight - 100,
            674,
          ),
      ),
      clipBehavior: isMobile ? Clip.none : Clip.antiAlias,
      child: _buildRulesFilterForm(context, isMobile),
    );

    if (isMobile) {
      bodyWidget = Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SafeArea(child: bodyWidget),
        ),
      );
    } else {
      bodyWidget = Center(child: bodyWidget);
    }

    return bodyWidget;
  }

  Widget _buildRulesFilterForm(BuildContext context, bool isMobile) {
    final appLocalizations = AppLocalizations.of(context);

    Widget formWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            alignment: Alignment.center,
            child: Obx(
              () => Text(
                controller.actionType.value.getTitle(appLocalizations),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColor.m3SurfaceBackground,
                ),
              ),
            ),
          )
        else
          Container(
            height: 64,
            padding: _getPadding(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PositionedDirectional(
                  start: 0,
                  child: TMailButtonWidget.fromIcon(
                    icon: controller.imagePaths.icArrowBack,
                    tooltipMessage: appLocalizations.back,
                    backgroundColor: Colors.transparent,
                    onTapActionCallback: () => controller.closeView(context),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Obx(
                      () => Text(
                        controller.actionType.value.getTitle(appLocalizations),
                        textAlign: TextAlign.center,
                        style: ThemeUtils.textStyleM3BodyLarge.copyWith(
                          color: AppColor.m3SurfaceBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                        () => LabelInputFieldBuilder(
                      label: appLocalizations.ruleName,
                      hintText: appLocalizations.rulesNameHintTextInput,
                      textEditingController:
                      controller.inputRuleNameController,
                      focusNode: controller.inputRuleNameFocusNode,
                      errorText: controller.errorRuleName.value,
                      arrangeHorizontally: false,
                      isLabelHasColon: false,
                      labelStyle: ThemeUtils.textStyleInter600().copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                        color: Colors.black,
                      ),
                      runSpacing: 16,
                      inputFieldMaxWidth: double.infinity,
                      onTextChange: (value) =>
                          controller.updateRuleName(context, value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Text(
                      appLocalizations.condition,
                      style: ThemeUtils.textStyleInter600().copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Obx(
                        () => RuleFilterTitle(
                      conditionCombinerType: controller.conditionCombinerType.value,
                      imagePaths: controller.imagePaths,
                      isMobile: isMobile,
                      onTapActionCallback: (value) =>
                          controller.selectConditionCombiner(
                            context: context,
                            combinerType: value,
                            isMobile: isMobile,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildListRuleFilterConditionList(
                    context: context,
                    isMobile: isMobile,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 161),
                    height: 36,
                    margin: const EdgeInsetsDirectional.only(top: 12),
                    child: ConfirmDialogButton(
                      label: AppLocalizations.of(context).addACondition,
                      backgroundColor: Colors.white,
                      textColor: AppColor.primaryMain,
                      borderColor: AppColor.primaryMain,
                      icon: controller.imagePaths.icAddIdentity,
                      onTapAction: controller.tapAddCondition,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 24,
                      bottom: 8,
                    ),
                    child: Text(
                      appLocalizations.actionsToPerform,
                      style: ThemeUtils.textStyleInter600().copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildListRuleFilterActionList(context),
                  Obx(() {
                    if (controller.isShowAddAction.value == true) {
                      return Container(
                        constraints: const BoxConstraints(minWidth: 161),
                        height: 36,
                        margin: const EdgeInsetsDirectional.only(top: 4),
                        child: ConfirmDialogButton(
                          label: AppLocalizations.of(context).addAnAction,
                          backgroundColor: Colors.white,
                          textColor: AppColor.primaryMain,
                          borderColor: AppColor.primaryMain,
                          icon: controller.imagePaths.icAddIdentity,
                          onTapAction: controller.tapAddAction,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
        RuleFilterListActionWidget(
          positiveLabel: appLocalizations.createRule,
          negativeLabel: appLocalizations.cancel,
          padding: EdgeInsets.symmetric(
            vertical: 25,
            horizontal: isMobile ? 16 : 32,
          ),
          onPositiveAction: () => controller.createNewRuleFilter(context),
          onNegativeAction: () => controller.closeView(context),
        ),
      ],
    );

    if (isMobile) {
      return formWidget;
    } else {
      return Stack(
        children: [
          formWidget,
          DefaultCloseButtonWidget(
            iconClose: controller.imagePaths.icCloseDialog,
            onTapActionCallback: () => controller.closeView(context),
          ),
        ],
      );
    }
  }

  Widget _buildListRuleFilterConditionList({
    required BuildContext context,
    required bool isMobile,
  }) {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: controller.listRuleCondition.length,
        itemBuilder: (context, index) {
          final conditionItem =
            controller.listRuleConditionValueArguments[index];
          return RuleFilterConditionWidget(
            key: ValueKey(conditionItem.focusNode),
            isMobile: isMobile,
            ruleCondition: controller.listRuleCondition[index],
            imagePaths: controller.imagePaths,
            conditionValueErrorText: conditionItem.errorText,
            conditionValueFocusNode: conditionItem.focusNode,
            textEditingController: conditionItem.controller,
            tapRuleConditionFieldCallback: (value) =>
                controller.selectRuleConditionFieldAction(
                  context,
                  value,
                  controller.listRuleCondition[index].field,
                  isMobile,
                  index,
                ),
            tapRuleConditionComparatorCallback: (value) =>
                controller.selectRuleConditionComparatorAction(
                  context,
                  value,
                  controller.listRuleCondition[index].comparator,
                  isMobile,
                  index,
                ),
            conditionValueOnChangeAction: (value) =>
              controller.updateConditionValue(context, value, index),
            onDeleteRuleConditionAction: () =>
                controller.tapRemoveCondition(index),
          );
        },
      );
    });
  }

  Widget _buildListRuleFilterActionList(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: controller.listEmailRuleFilterActionSelected.length,
        padding: const EdgeInsetsDirectional.only(bottom: 8),
        itemBuilder: (context, index) {
          final currentAction = controller.listEmailRuleFilterActionSelected[index];
          String? errorValue;
          if (currentAction is ForwardActionArguments) {
            errorValue = controller.errorForwardEmailValue.value;
          } else {
            errorValue = controller.errorMailboxSelectedValue.value;
          }
          return RuleFilterActionWidget(
            responsiveUtils: controller.responsiveUtils,
            mailboxSelected: currentAction is MoveMessageActionArguments
              ? currentAction.mailbox
              : null,
            errorValue: errorValue,
            onActionChangeMobile: () {
              controller.selectRuleFilterAction(
                context,
                currentAction.action,
                index,
              );
            },
            onActionChanged: (newAction) {
              if (newAction != currentAction.action) {
                controller.updateEmailRuleFilterAction(
                  context,
                  newAction,
                  index,
                );
              }
            },
            forwardEmailEditingController: currentAction.action == EmailRuleFilterAction.forwardTo
                ? controller.forwardEmailController
                : null,
            forwardEmailFocusNode: currentAction.action == EmailRuleFilterAction.forwardTo
              ? controller.forwardEmailFocusNode
              : null,
            onChangeForwardEmail: (value) => controller.updateForwardEmailValue(context, value, index),
            actionSelected: currentAction.action,
            tapActionDetailedCallback: () {
              KeyboardUtils.hideKeyboard(context);
              controller.selectMailbox(context, index);
            },
            onDeleteRuleConditionAction: () =>
                controller.tapRemoveAction(index),
            imagePaths: controller.imagePaths,
          );
        },
      );
    });
  }

  EdgeInsetsGeometry _getPadding(BuildContext context) {
    if (controller.responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsetsDirectional.only(start: 8, end: 16);
    } else if (controller.responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 24);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32);
    }
  }
}