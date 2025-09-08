import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:core/presentation/resources/image_paths.dart';

class RuleFilterConditionWidget extends StatelessWidget {
  final RuleFilterConditionScreenType? ruleFilterConditionScreenType;
  final RuleCondition ruleCondition;
  final TextEditingController textEditingController;
  final Function(Field?)? tapRuleConditionFieldCallback;
  final Function(Comparator?)? tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final FocusNode? conditionValueFocusNode;
  final OnChangeFilterInputAction? conditionValueOnChangeAction;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;

  const RuleFilterConditionWidget({
    super.key,
    this.ruleFilterConditionScreenType,
    required this.ruleCondition,
    required this.imagePaths,
    required this.textEditingController,
    required this.onDeleteRuleConditionAction,
    this.tapRuleConditionFieldCallback,
    this.tapRuleConditionComparatorCallback,
    this.conditionValueErrorText,
    this.conditionValueFocusNode,
    this.conditionValueOnChangeAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Container(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
      margin: const EdgeInsetsDirectional.only(top: 8),
      decoration: const BoxDecoration(
        color: AppColor.lightGrayF9FAFB,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      alignment: Alignment.center,
      child: RuleFilterConditionRow(
        ruleFilterConditionScreenType: ruleFilterConditionScreenType,
        ruleCondition: ruleCondition,
        tapRuleConditionFieldCallback: tapRuleConditionFieldCallback,
        tapRuleConditionComparatorCallback: tapRuleConditionComparatorCallback,
        conditionValueErrorText: conditionValueErrorText,
        textEditingController: textEditingController,
        conditionValueFocusNode: conditionValueFocusNode,
        conditionValueOnChangeAction: conditionValueOnChangeAction,
        onDeleteRuleConditionAction: onDeleteRuleConditionAction,
        imagePaths: imagePaths,
      ),
    );

    if (ruleFilterConditionScreenType != RuleFilterConditionScreenType.mobile) {
      return bodyWidget;
    }

    return Slidable(
      enabled: ruleFilterConditionScreenType == RuleFilterConditionScreenType.mobile ? true : false,
      endActionPane: ActionPane(
        extentRatio: 0.1,
        motion: const BehindMotion(),
        children: [
          CustomSlidableAction(
            padding: const EdgeInsets.only(right: 12),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
            onPressed: (_) => onDeleteRuleConditionAction(),
            backgroundColor: AppColor.colorBackgroundFieldConditionRulesFilter,
            child: CircleAvatar(
              backgroundColor: AppColor.colorRemoveRuleFilterConditionButton,
              radius: 110,
              child: SvgPicture.asset(
                imagePaths.icMinimize,
                fit: BoxFit.fill,
                colorFilter: AppColor.colorDeletePermanentlyButton.asFilter(),
              ),
            )
          )
        ]
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: Slidable.of(context)?.direction ?? ValueNotifier<int>(0),
        builder: (_, __, ___) => bodyWidget,
      ),
    );
  }
}