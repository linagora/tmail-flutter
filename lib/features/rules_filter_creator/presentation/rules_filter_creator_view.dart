import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_action_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_condition_comparator_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_condition_field_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RuleFilterCreatorView extends GetWidget<RulesFilterCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  final controller = Get.find<RulesFilterCreatorController>();

  RuleFilterCreatorView({Key? key}) : super(key: key) {
    controller.arguments = Get.arguments;
  }

  RuleFilterCreatorView.fromArguments(
      RulesFilterCreatorArguments arguments, {
      Key? key,
      OnCreatedRuleFilterCallback? onCreatedRuleFilterCallback,
      VoidCallback? onDismissCallback
  }) : super(key: key) {
    controller.arguments = arguments;
    controller.onCreatedRuleFilterCallback = onCreatedRuleFilterCallback;
    controller.onDismissRuleFilterCreator = onDismissCallback;
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          mobile: Scaffold(
              backgroundColor: BuildUtils.isWeb
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
                    margin: const EdgeInsets.only(top: BuildUtils.isWeb ? 70 : 0),
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
                    height: _responsiveUtils.getSizeScreenHeight(context) * 0.7,
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
                        width: _responsiveUtils.getSizeScreenWidth(context) * 0.6,
                        height: _responsiveUtils.getSizeScreenHeight(context) * 0.7,
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
                style: const TextStyle(
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
                  Text(AppLocalizations.of(context).conditionTitleRulesFilter,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: const TextStyle(
                       fontWeight: FontWeight.w500,
                       fontSize: 16,
                       color: Colors.black)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.colorBackgroundFieldConditionRulesFilter, 
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Obx(() => DropDownButtonWidget<rule_condition.Field>(
                          items: rule_condition.Field.values,
                          itemSelected: controller.ruleConditionFieldSelected.value,
                          dropdownMaxHeight: 250,
                          onChanged: (newField) =>
                            controller.selectRuleConditionField(newField),
                          supportSelectionIcon: true))),
                        Container(
                          width: 220,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Obx(() => DropDownButtonWidget<rule_condition.Comparator>(
                            items: rule_condition.Comparator.values,
                            itemSelected: controller.ruleConditionComparatorSelected.value,
                            onChanged: (newComparator) =>
                              controller.selectRuleConditionComparator(newComparator),
                            supportSelectionIcon: true))),
                        Expanded(child: Obx(() => RulesFilterInputField(
                          hintText: AppLocalizations.of(context).conditionValueHintTextInput,
                          errorText: controller.errorRuleConditionValue.value,
                          editingController: controller.inputConditionValueController,
                          focusNode: controller.inputRuleConditionFocusNode,
                          onChangeAction: (value) =>
                            controller.updateConditionValue(context, value))))
                      ]
                    )
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context).actionTitleRulesFilter,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.colorBackgroundFieldConditionRulesFilter,
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Expanded(child: Obx(() => DropDownButtonWidget<EmailRuleFilterAction>(
                        items: EmailRuleFilterAction.values,
                        itemSelected: controller.emailRuleFilterActionSelected.value,
                        onChanged: (newAction) =>
                          controller.selectEmailRuleFilterAction(newAction),
                        supportSelectionIcon: true))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          AppLocalizations.of(context).toMailbox,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.black)),
                      ),
                      Expanded(child: Obx(() =>
                        RuleFilterButtonField<PresentationMailbox>(
                          value: controller.mailboxSelected.value,
                          borderColor: _getBorderColorMailboxSelected(),
                          tapActionCallback: (value) {
                            FocusScope.of(context).unfocus();
                            controller.selectMailbox(context);
                          }))),
                    ])
                  ),
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
                  textStyle: const TextStyle(
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
                  _imagePaths.icCloseMailbox,
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
                    style: const TextStyle(
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
                      Text(AppLocalizations.of(context).conditionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColor.colorBackgroundFieldConditionRulesFilter,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Obx(() => DropDownButtonWidget<rule_condition.Field>(
                                    items: rule_condition.Field.values,
                                    itemSelected: controller.ruleConditionFieldSelected.value,
                                    dropdownMaxHeight: 250,
                                    onChanged: (newField) =>
                                        controller.selectRuleConditionField(newField),
                                    supportSelectionIcon: true))),
                                Container(
                                    width: 220,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Obx(() => DropDownButtonWidget<rule_condition.Comparator>(
                                        items: rule_condition.Comparator.values,
                                        itemSelected: controller.ruleConditionComparatorSelected.value,
                                        onChanged: (newComparator) =>
                                            controller.selectRuleConditionComparator(newComparator),
                                        supportSelectionIcon: true))),
                                Expanded(child: Obx(() => RulesFilterInputField(
                                    hintText: AppLocalizations.of(context).conditionValueHintTextInput,
                                    errorText: controller.errorRuleConditionValue.value,
                                    editingController: controller.inputConditionValueController,
                                    focusNode: controller.inputRuleConditionFocusNode,
                                    onChangeAction: (value) =>
                                        controller.updateConditionValue(context, value))))
                              ]
                          )
                      ),
                      const SizedBox(height: 24),
                      Text(AppLocalizations.of(context).actionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColor.colorBackgroundFieldConditionRulesFilter,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            Expanded(child: Obx(() => DropDownButtonWidget<EmailRuleFilterAction>(
                                items: EmailRuleFilterAction.values,
                                itemSelected: controller.emailRuleFilterActionSelected.value,
                                onChanged: (newAction) =>
                                    controller.selectEmailRuleFilterAction(newAction),
                                supportSelectionIcon: true))),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                  AppLocalizations.of(context).toMailbox,
                                  overflow: CommonTextStyle.defaultTextOverFlow,
                                  softWrap: CommonTextStyle.defaultSoftWrap,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black)),
                            ),
                            Expanded(child: Obx(() =>
                              RuleFilterButtonField<PresentationMailbox>(
                                value: controller.mailboxSelected.value,
                                borderColor: _getBorderColorMailboxSelected(),
                                tapActionCallback: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.selectMailbox(context);
                                }))),
                          ])
                      ),
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
                        textStyle: const TextStyle(
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
                      _imagePaths.icCloseMailbox,
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
                    style: const TextStyle(
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
                        child: Divider(
                            color: AppColor.colorDividerRuleFilter,
                            height: 1,
                            thickness: 0.2),
                      ),
                      Text(AppLocalizations.of(context).conditionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColor.colorBackgroundFieldConditionRulesFilter,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  return RuleFilterButtonField<rule_condition.Field>(
                                      value: controller.ruleConditionFieldSelected.value,
                                      tapActionCallback: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.openContextMenuAction(
                                            context,
                                            _bottomSheetRuleConditionFieldActionTiles(
                                                context,
                                                controller.ruleConditionFieldSelected.value));
                                      }
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Obx(() {
                                    return RuleFilterButtonField<rule_condition.Comparator>(
                                        value: controller.ruleConditionComparatorSelected.value,
                                        tapActionCallback: (value) {
                                          FocusScope.of(context).unfocus();
                                          controller.openContextMenuAction(
                                              context,
                                              _bottomSheetRuleConditionComparatorActionTiles(
                                                  context,
                                                  controller.ruleConditionComparatorSelected.value));
                                        }
                                    );
                                  }),
                                ),
                                Obx(() => RulesFilterInputField(
                                    hintText: AppLocalizations.of(context).conditionValueHintTextInput,
                                    errorText: controller.errorRuleConditionValue.value,
                                    editingController: controller.inputConditionValueController,
                                    focusNode: controller.inputRuleConditionFocusNode,
                                    onChangeAction: (value) =>
                                        controller.updateConditionValue(context, value)))
                              ]
                          )
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                            color: AppColor.colorDividerRuleFilter,
                            height: 1),
                      ),
                      Text(AppLocalizations.of(context).actionTitleRulesFilter,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 24),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColor.colorBackgroundFieldConditionRulesFilter,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [
                            Obx(() {
                              return RuleFilterButtonField<EmailRuleFilterAction>(
                                value: controller.emailRuleFilterActionSelected.value,
                                tapActionCallback: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.openContextMenuAction(
                                      context,
                                      _bottomSheetActionRuleFilterActionTiles(
                                          context,
                                          controller.emailRuleFilterActionSelected.value));
                                }
                              );
                            }),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                  AppLocalizations.of(context).toMailbox,
                                  overflow: CommonTextStyle.defaultTextOverFlow,
                                  softWrap: CommonTextStyle.defaultSoftWrap,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black)),
                            ),
                            Obx(() => RuleFilterButtonField<PresentationMailbox>(
                              value: controller.mailboxSelected.value,
                              borderColor: _getBorderColorMailboxSelected(),
                              tapActionCallback: (value) {
                                FocusScope.of(context).unfocus();
                                controller.selectMailbox(context);
                              }))
                          ])
                      ),
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
                        textStyle: const TextStyle(
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
                      _imagePaths.icCloseMailbox,
                      fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).close,
                  onTap: () => controller.closeView(context)))
        ]
    );
  }

  List<Widget> _bottomSheetRuleConditionFieldActionTiles(
      BuildContext context,
      rule_condition.Field? fieldSelected
  ) {
    return rule_condition.Field.values
      .map((field) =>
        _buildRuleConditionFieldWidget(context, field, fieldSelected))
      .toList();
  }

  Widget _buildRuleConditionFieldWidget(
      BuildContext context,
      rule_condition.Field field,
      rule_condition.Field? fieldSelected
  ) {
    return (RuleConditionFieldSheetActionTileBuilder(
        field.getTitle(context),
        fieldSelected,
        field,
        iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
        iconRightPadding: const EdgeInsets.only(right: 12),
        actionSelected: SvgPicture.asset(
            _imagePaths.icFilterSelected,
            width: 20,
            height: 20,
            fit: BoxFit.fill))
      ..onActionClick((field) {
        controller.selectRuleConditionField(field);
        popBack();
      }))
    .build();
  }

  List<Widget> _bottomSheetRuleConditionComparatorActionTiles(
      BuildContext context,
      rule_condition.Comparator? comparatorSelected
  ) {
    return rule_condition.Comparator.values
      .map((comparator) =>
        _buildRuleConditionComparatorWidget(context, comparator, comparatorSelected))
      .toList();
  }

  Widget _buildRuleConditionComparatorWidget(
      BuildContext context,
      rule_condition.Comparator comparator,
      rule_condition.Comparator? comparatorSelected
  ) {
    return (RuleConditionComparatorSheetActionTileBuilder(
        comparator.getTitle(context),
        comparatorSelected,
        comparator,
        iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
        iconRightPadding: const EdgeInsets.only(right: 12),
        actionSelected: SvgPicture.asset(
            _imagePaths.icFilterSelected,
            width: 20,
            height: 20,
            fit: BoxFit.fill))
      ..onActionClick((comparator) {
        controller.selectRuleConditionComparator(comparator);
        popBack();
      }))
    .build();
  }

  List<Widget> _bottomSheetActionRuleFilterActionTiles(
      BuildContext context,
      EmailRuleFilterAction? ruleActionSelected
  ) {
    return EmailRuleFilterAction.values
      .map((ruleAction) =>
        _buildRuleActionWidget(context, ruleAction, ruleActionSelected))
      .toList();
  }

  Widget _buildRuleActionWidget(
      BuildContext context,
      EmailRuleFilterAction ruleAction,
      EmailRuleFilterAction? ruleActionSelected
  ) {
    return (RuleActionSheetActionTileBuilder(
        ruleAction.getTitle(context),
        ruleActionSelected,
        ruleAction,
        iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
        iconRightPadding: const EdgeInsets.only(right: 12),
        actionSelected: SvgPicture.asset(
            _imagePaths.icFilterSelected,
            width: 20,
            height: 20,
            fit: BoxFit.fill))
      ..onActionClick((ruleAction) {
        controller.selectEmailRuleFilterAction(ruleAction);
        popBack();
      }))
    .build();
  }

  Color _getBorderColorMailboxSelected() {
    if (controller.errorRuleActionValue.value?.isNotEmpty == true) {
      return AppColor.colorInputBorderErrorVerifyName;
    } else {
      return AppColor.colorInputBorderCreateMailbox;
    }
  }
}