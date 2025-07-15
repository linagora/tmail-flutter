import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/select_rule_action_field_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/styles/rule_filter_action_styles.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_list.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_title_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterCreatorView extends GetWidget<RulesFilterCreatorController> {

  @override
  final controller = Get.find<RulesFilterCreatorController>();

  RuleFilterCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: ResponsiveWidget(
          responsiveUtils: controller.responsiveUtils,
          mobile: Scaffold(
              backgroundColor: PlatformInfo.isWeb
                  ? Colors.black.withAlpha(24)
                  : Colors.black38,
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SafeArea(
                  bottom: false,
                  left: false,
                  right: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                      color: Colors.white),
                    margin: EdgeInsets.only(top: PlatformInfo.isWeb ? 70 : 0),
                    child: ClipRRect(
                        borderRadius: const  BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: SafeArea(child: _buildRulesFilterFormOnMobile(context))
                    )
                  ),
                ),
              )
          ),
          tablet: Scaffold(
              backgroundColor: Colors.black.withAlpha(24),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Align(alignment: Alignment.bottomCenter, child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )),
                    width: double.infinity,
                    height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.7,
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                        child: _buildRulesFilterFormOnTablet(context)
                    )
                )),
              )
          ),
          desktop: Scaffold(
              backgroundColor: Colors.black.withAlpha(24),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Center(child: Card(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        width: controller.responsiveUtils.getSizeScreenWidth(context) * 0.6,
                        height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.7,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            child: _buildRulesFilterFormOnDesktop(context)
                        )
                    )
                )),
              )
          )
      ),
    );
  }

  Widget _buildRulesFilterFormOnDesktop(BuildContext context) {
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.only(top: 16),
            alignment: Alignment.center,
            child: Obx(() => Text(
                controller.actionType.value.getTitle(context),
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
                  const SizedBox(height: 24),
                  Obx(() => RuleFilterTitle(
                    conditionCombinerType: controller.conditionCombinerType.value,
                    tapActionCallback: (value) => controller.selectConditionCombiner(value),
                    ruleFilterConditionScreenType: RuleFilterConditionScreenType.desktop,
                  )),
                  const SizedBox(height: 24),
                  _buildListRuleFilterConditionList(context, RuleFilterConditionScreenType.desktop),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: controller.tapAddCondition,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context).actionTitleRulesFilter,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black)),
                  const SizedBox(height: 24),
                  Obx(() {
                    return RuleFilterActionListWidget(
                      responsiveUtils: controller.responsiveUtils,
                      actionList: controller.listEmailRuleFilterActionSelected,
                      onActionChanged: (newAction, index) {
                        controller.updateEmailRuleFilterAction(context, newAction, index);
                      },
                      forwardEmailEditingController: controller.forwardEmailController,
                      forwardEmailFocusNode: controller.forwardEmailFocusNode,
                      onChangeForwardEmail: (value, index) => controller.updateForwardEmailValue(context, value, index),
                      tapActionDetailedCallback: (index) {
                        KeyboardUtils.hideKeyboard(context);
                        controller.selectMailbox(context, index);
                      },
                      tapRemoveCallback: (index) => controller.tapRemoveAction(index),
                      imagePaths: controller.imagePaths,
                      errorForwardEmail: controller.errorForwardEmailValue.value,
                      errorMailboxSelected: controller.errorMailboxSelectedValue.value,
                    );
                  }),
                  Obx(() {
                    if (controller.isShowAddAction.value == true) {
                      return Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: controller.tapAddAction,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                controller.imagePaths.icAddNewFolder,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(width: 15,),
                              Text(
                                AppLocalizations.of(context).addAction,
                                maxLines: RuleFilterActionStyles.maxLines,
                                style: RuleFilterActionStyles.addActionButtonTextStyle
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
                ]
              ),
            ),
          )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            alignment: Alignment.centerRight,
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextButton(
                  AppLocalizations.of(context).cancel,
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: AppColor.colorTextButton),
                  backgroundColor: AppColor.emailAddressChipColor,
                  width: 128,
                  height: 44,
                  radius: 10,
                  onTap: () => controller.closeView(context)),
                const SizedBox(width: 12),
                Obx(() => buildTextButton(
                  controller.actionType.value.getActionName(context),
                  width: 128,
                  height: 44,
                  backgroundColor: AppColor.colorTextButton,
                  radius: 10,
                  onTap: () => controller.createNewRuleFilter(context))),
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

  Widget _buildRulesFilterFormOnTablet(BuildContext context) {
    return Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: Obx(() => Text(
                    controller.actionType.value.getTitle(context),
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
                      const SizedBox(height: 24),
                      Obx(() => RuleFilterTitle(
                        conditionCombinerType: controller.conditionCombinerType.value,
                        tapActionCallback: (value) => controller.selectConditionCombiner(value),
                        ruleFilterConditionScreenType: RuleFilterConditionScreenType.tablet,
                      )),
                      const SizedBox(height: 24),
                      _buildListRuleFilterConditionList(context, RuleFilterConditionScreenType.tablet),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: controller.tapAddCondition,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(height: 24),
                      Text(AppLocalizations.of(context).actionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
                      Obx(() {
                        return RuleFilterActionListWidget(
                          responsiveUtils: controller.responsiveUtils,
                          actionList: controller.listEmailRuleFilterActionSelected,
                          onActionChanged: (newAction, index) {
                            controller.updateEmailRuleFilterAction(context, newAction, index);
                          },
                          forwardEmailEditingController: controller.forwardEmailController,
                          forwardEmailFocusNode: controller.forwardEmailFocusNode,
                          onChangeForwardEmail: (value, index) => controller.updateForwardEmailValue(context, value, index),
                          tapActionDetailedCallback: (index) {
                            KeyboardUtils.hideKeyboard(context);
                            controller.selectMailbox(context, index);
                          },
                          tapRemoveCallback: (index) => controller.tapRemoveAction(index),
                          imagePaths: controller.imagePaths,
                          errorForwardEmail: controller.errorForwardEmailValue.value,
                          errorMailboxSelected: controller.errorMailboxSelectedValue.value,
                        );
                      }),
                      Obx(() {
                        if (controller.isShowAddAction.value == true) {
                          return Container(
                            padding: const EdgeInsets.only(top: 8),
                            child: InkWell(
                              onTap: controller.tapAddAction,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    controller.imagePaths.icAddNewFolder,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(width: 15,),
                                  Text(
                                    AppLocalizations.of(context).addAction,
                                    maxLines: RuleFilterActionStyles.maxLines,
                                    style: RuleFilterActionStyles.addActionButtonTextStyle
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
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

  Widget _buildRulesFilterFormOnMobile(BuildContext context) {
    return Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: Obx(() => Text(
                    controller.actionType.value.getTitle(context),
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
                      Obx(() {
                        return RuleFilterActionListWidget(
                          responsiveUtils: controller.responsiveUtils,
                          actionList: controller.listEmailRuleFilterActionSelected,
                          onActionChangeMobile: (currentAction, index) {
                            controller.selectRuleFilterAction(
                              context,
                              currentAction,
                              index
                            );
                          },
                          forwardEmailEditingController: controller.forwardEmailController,
                          forwardEmailFocusNode: controller.forwardEmailFocusNode,
                          onChangeForwardEmail: (value, index) => controller.updateForwardEmailValue(context, value, index),
                          tapActionDetailedCallback: (index) {
                            KeyboardUtils.hideKeyboard(context);
                            controller.selectMailbox(context, index);
                          },
                          tapRemoveCallback: (index) => controller.tapRemoveAction(index),
                          imagePaths: controller.imagePaths,
                          errorForwardEmail: controller.errorForwardEmailValue.value,
                          errorMailboxSelected: controller.errorMailboxSelectedValue.value,
                        );
                      }),
                      Obx(() {
                        if (controller.isShowAddAction.value == true) {
                          return Container(
                            padding: const EdgeInsets.only(top: 12),
                            child: InkWell(
                              onTap: controller.tapAddAction,
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
                                    AppLocalizations.of(context).addAction,
                                    maxLines: RuleFilterActionStyles.maxLines,
                                    style: RuleFilterActionStyles.addActionButtonTextStyle
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
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
    RuleFilterConditionScreenType ruleFilterConditionScreenType
  ) {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: controller.listRuleCondition.length,
        itemBuilder: (context, index) {
          return RuleFilterConditionWidget(
            key: ValueKey(controller.listRuleConditionValueArguments[index].focusNode),
            ruleFilterConditionScreenType: ruleFilterConditionScreenType,
            ruleCondition: controller.listRuleCondition[index],
            imagePaths: controller.imagePaths,
            conditionValueErrorText: controller.listRuleConditionValueArguments[index].errorText,
            conditionValueFocusNode: controller.listRuleConditionValueArguments[index].focusNode,
            conditionValueEditingController: controller.listRuleConditionValueArguments[index].controller,
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
            tapRemoveRuleFilterConditionCallback: () => controller.tapRemoveCondition(index),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12,);
        },
      );
    });
  }
}