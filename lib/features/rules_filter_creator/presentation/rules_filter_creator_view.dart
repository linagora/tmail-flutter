import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/base/widget/pop_back_barrier_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/handle_toggle_preview_rule_filter_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/select_rule_action_field_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_list_action_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_title_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_title_with_preview_button.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_preview_banner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterCreatorView extends GetWidget<RulesFilterCreatorController> {

  @override
  final controller = Get.find<RulesFilterCreatorController>();

  RuleFilterCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = controller.responsiveUtils;
    final isMobile = responsiveUtils.isMobile(context);
    final isAllTablet = responsiveUtils.isPortraitTablet(context) ||
        responsiveUtils.isLandscapeTablet(context);

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
      width: _getViewWidth(
        isMobile,
        responsiveUtils.getSizeScreenWidth(context),
      ),
      constraints: BoxConstraints(
        maxHeight: _getViewMaxHeight(
          isMobile,
          responsiveUtils.getSizeScreenHeight(context),
        ),
      ),
      clipBehavior: isMobile ? Clip.none : Clip.antiAlias,
      child: _buildRulesFilterForm(context, isMobile, responsiveUtils),
    );

    if (isMobile) {
      bodyWidget = Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SafeArea(child: bodyWidget),
        ),
      );
    } else if (isAllTablet && PlatformInfo.isMobile) {
      bodyWidget = Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        body: PopBackBarrierWidget(
          child: Center(
            child: GestureDetector(
              onTap: FocusScope.of(context).unfocus,
              child: bodyWidget,
            ),
          ),
        ),
      );
    } else {
      bodyWidget = Center(child: bodyWidget);
    }

    return bodyWidget;
  }

  Widget _buildRulesFilterForm(
    BuildContext context,
    bool isMobile,
    ResponsiveUtils responsiveUtils,
  ) {
    final appLocalizations = AppLocalizations.of(context);

    Widget formWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
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
            padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
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
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => LabelInputFieldBuilder(
                      label: appLocalizations.ruleName,
                      hintText: appLocalizations.rulesNameHintTextInput,
                      textEditingController: controller.inputRuleNameController,
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
                      onTextChange: (value) => controller.updateRuleName(
                        appLocalizations,
                        value,
                      ),
                    ),
                  ),
                  if (!isMobile)
                    Obx(() => RuleFilterTitleWithPreviewButton(
                      imagePaths: controller.imagePaths,
                      isPreviewEnabled: controller.isPreviewEnabled.value,
                      onTogglePreviewAction:
                        controller.handleTogglePreviewRuleFilter,
                    ))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        appLocalizations.condition,
                        style: ThemeUtils.textStyleInter600().copyWith(
                          fontSize: 14,
                          height: 18 / 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (!isMobile)
                    Obx(() {
                      if (controller.isPreviewEnabled.isTrue) {
                        return RulePreviewBanner(
                          imagePaths: controller.imagePaths,
                          message: controller.getConditionPreview(
                            appLocalizations,
                          ),
                          isAction: false,
                          margin: const EdgeInsetsDirectional.only(bottom: 16),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  Obx(
                    () => RuleFilterTitle(
                      conditionCombinerType: controller
                        .conditionCombinerType
                        .value,
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
                  Obx(() {
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: controller.listRuleCondition.length,
                      itemBuilder: (context, index) {
                        final conditionItem = controller
                            .listRuleConditionValueArguments[index];

                        return RuleFilterConditionWidget(
                          key: ValueKey(conditionItem.focusNode),
                          isMobile: isMobile,
                          ruleCondition: controller.listRuleCondition[index],
                          imagePaths: controller.imagePaths,
                          conditionValueErrorText: conditionItem.errorText,
                          conditionValueFocusNode: conditionItem.focusNode,
                          textEditingController: conditionItem.controller,
                          tapRuleConditionFieldCallback: (value) {
                            controller.selectRuleConditionFieldAction(
                              context,
                              value,
                              controller.listRuleCondition[index].field,
                              isMobile,
                              index,
                            );
                          },
                          tapRuleConditionComparatorCallback: (value) {
                            controller.selectRuleConditionComparatorAction(
                              context,
                              value,
                              controller.listRuleCondition[index].comparator,
                              isMobile,
                              index,
                            );
                          },
                          conditionValueOnChangeAction: (value) {
                            controller.updateConditionValue(
                              appLocalizations,
                              value,
                              index,
                            );
                          },
                          onDeleteRuleConditionAction: () {
                            controller.tapRemoveCondition(index);
                          },
                        );
                      },
                    );
                  }),
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
                  if (!isMobile)
                    Obx(() {
                      if (controller.isPreviewEnabled.isTrue) {
                        return RulePreviewBanner(
                          imagePaths: controller.imagePaths,
                          message: controller.getActionPreview(context),
                          isAction: true,
                          margin: const EdgeInsetsDirectional.only(
                            top: 8,
                            bottom: 8,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  Obx(() {
                    final listActions = controller
                        .listEmailRuleFilterActionSelected;

                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: listActions.length,
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      itemBuilder: (context, index) {
                        final action = listActions[index];
                        final isForwardTo =
                            action.action?.isForwardTo == true;

                        final errorValue = action is ForwardActionArguments
                          ? controller.errorForwardEmailValue.value
                          : controller.errorMailboxSelectedValue.value;

                        return RuleFilterActionWidget(
                          isMobile: isMobile,
                          mailboxSelected: action is MoveMessageActionArguments
                              ? action.mailbox
                              : null,
                          errorValue: errorValue,
                          onActionChangeMobile: () {
                            controller.selectRuleFilterAction(
                              context,
                              action.action,
                              index,
                            );
                          },
                          onActionChanged: (newAction) {
                            if (newAction != action.action) {
                              controller.updateEmailRuleFilterAction(
                                context,
                                newAction,
                                index,
                              );
                            }
                          },
                          forwardEmailEditingController: isForwardTo
                              ? controller.forwardEmailController
                              : null,
                          forwardEmailFocusNode: isForwardTo
                              ? controller.forwardEmailFocusNode
                              : null,
                          onChangeForwardEmail: (value) {
                            controller.updateForwardEmailValue(
                              appLocalizations,
                              value,
                              index,
                            );
                          },
                          actionSelected: action.action,
                          onTapActionDetailedCallback: () {
                            FocusScope.of(context).unfocus();
                            controller.selectMailbox(context, index);
                          },
                          onDeleteRuleConditionAction: () {
                            controller.tapRemoveAction(index);
                          },
                          imagePaths: controller.imagePaths,
                        );
                      },
                    );
                  }),
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
          onPositiveAction: () {
            FocusScope.of(context).unfocus();
            controller.createNewRuleFilter(context);
          },
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

  double _getViewWidth(bool isMobile, double screenWidth) {
    return isMobile ? double.infinity : math.min(screenWidth, 612);
  }

  double _getViewMaxHeight(bool isMobile, double screenHeight) {
    final screenHeightWithoutPadding =
        screenHeight > 100 ? screenHeight - 100 : screenHeight;

    return isMobile
        ? double.infinity
        : math.min(screenHeightWithoutPadding, 674);
  }
}