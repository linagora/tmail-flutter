import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/base/widget/pop_back_barrier_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/select_rule_action_field_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_list_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_title_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterCreatorView extends GetWidget<RulesFilterCreatorController> {

  @override
  final controller = Get.find<RulesFilterCreatorController>();

  RuleFilterCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsiveUtil = controller.responsiveUtils;
    final isMobile = responsiveUtil.isMobile(context);
    final focusScope = FocusScope.of(context);
    final currentScreenHeight = responsiveUtil.getSizeScreenHeight(context);
    final currentScreenWidth = responsiveUtil.getSizeScreenWidth(context);

    if (!isMobile) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
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
          width: math.min(
            currentScreenWidth,
            612,
          ),
          constraints: BoxConstraints(
            maxHeight: math.min(
              currentScreenHeight - 100,
              674,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildRulesFilterFormOnDesktop(context),
        ),
      );
    }

    return ResponsiveWidget(
      responsiveUtils: responsiveUtil,
      mobile: Scaffold(
        backgroundColor:
            PlatformInfo.isWeb ? Colors.black.withAlpha(24) : Colors.black38,
        body: PopBackBarrierWidget(
          child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: GestureDetector(
              onTap: focusScope.unfocus,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: PlatformInfo.isWeb ? 70 : 0),
                child: SafeArea(
                  child: _buildRulesFilterFormOnMobile(context),
                ),
              ),
            ),
          ),
        ),
      ),
      tablet: Scaffold(
        backgroundColor: Colors.black.withAlpha(24),
        body: Center(
          child: GestureDetector(
            onTap: focusScope.unfocus,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                boxShadow: [
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
              width: math.min(
                currentScreenWidth,
                612,
              ),
              constraints: BoxConstraints(
                maxHeight: math.min(
                  currentScreenHeight - 100,
                  674,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildRulesFilterFormOnDesktop(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulesFilterFormOnDesktop(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
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
                          conditionCombinerType:
                              controller.conditionCombinerType.value,
                          responsiveUtils: controller.responsiveUtils,
                          tapActionCallback: (value) =>
                              controller.selectConditionCombiner(value),
                          ruleFilterConditionScreenType:
                              RuleFilterConditionScreenType.desktop,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildListRuleFilterConditionList(
                        context,
                        RuleFilterConditionScreenType.desktop,
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
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 32),
              onPositiveAction: () => controller.createNewRuleFilter(context),
              onNegativeAction: () => controller.closeView(context),
            ),
          ],
        ),
        DefaultCloseButtonWidget(
          iconClose: controller.imagePaths.icCloseDialog,
          onTapActionCallback: () => controller.closeView(context),
        ),
      ],
    );
  }

  Widget _buildRulesFilterFormOnMobile(BuildContext context) {
    return Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: Obx(() => Text(
                    controller.actionType.value.getTitle(AppLocalizations.of(context)),
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black)))),
            Expanded(child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => RulesFilterInputField(
                        hintText: AppLocalizations.of(context).rulesNameHintTextInput,
                        errorText: controller.errorRuleName.value,
                        editingController: controller.inputRuleNameController,
                        focusNode: controller.inputRuleNameFocusNode,
                        onChangeAction: (value) => controller.updateRuleName(context, value),)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Obx(() => RuleFilterTitle(
                        conditionCombinerType: controller.conditionCombinerType.value,
                        responsiveUtils: controller.responsiveUtils,
                        ruleFilterConditionScreenType: RuleFilterConditionScreenType.mobile,
                        tapActionCallback: (_) {
                          controller.selectRuleConditionCombinerAction(
                            context,
                            controller.conditionCombinerType.value
                                ?? ConditionCombiner.AND,
                          );
                        },
                      )),
                      const SizedBox(height: 24),
                      _buildListRuleFilterConditionList(context, RuleFilterConditionScreenType.mobile),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        child: InkWell(
                          onTap: controller.tapAddCondition,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                controller.imagePaths.icAddNewFolder,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(width: 15,),
                              Text(
                                AppLocalizations.of(context).addCondition,
                                maxLines: 1,
                                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: AppColor.primaryColor
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Text(AppLocalizations.of(context).actionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
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
                    ]
                ),
              ),
            )),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              alignment: Alignment.center,
              color: Colors.white,
              child: Row(
                  children: [
                    Expanded(child: buildTextButton(
                        AppLocalizations.of(context).cancel,
                        textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: AppColor.colorTextButton),
                        backgroundColor: AppColor.emailAddressChipColor,
                        width: 128,
                        height: 44,
                        radius: 10,
                        onTap: () => controller.closeView(context))),
                    const SizedBox(width: 12),
                    Expanded(child: Obx(() => buildTextButton(
                        controller.actionType.value.getActionName(context),
                        width: 128,
                        height: 44,
                        backgroundColor: AppColor.colorTextButton,
                        radius: 10,
                        onTap: () => controller.createNewRuleFilter(context)))),
                  ]
              ),
            )
          ]),
          Positioned(top: 8, right: 8,
              child: buildIconWeb(
                  icon: SvgPicture.asset(
                      controller.imagePaths.icCircleClose,
                      fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).close,
                  onTap: () => controller.closeView(context)))
        ]
    );
  }

  Widget _buildListRuleFilterConditionList(
    BuildContext context,
    RuleFilterConditionScreenType ruleFilterConditionScreenType,
  ) {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: controller.listRuleCondition.length,
        itemBuilder: (context, index) {
          final conditionItem =
            controller.listRuleConditionValueArguments[index];
          return RuleFilterConditionWidget(
            key: ValueKey(conditionItem.focusNode),
            ruleFilterConditionScreenType: ruleFilterConditionScreenType,
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
                  ruleFilterConditionScreenType,
                  index,
                ),
            tapRuleConditionComparatorCallback: (value) =>
                controller.selectRuleConditionComparatorAction(
                  context,
                  value,
                  controller.listRuleCondition[index].comparator,
                  ruleFilterConditionScreenType,
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
}