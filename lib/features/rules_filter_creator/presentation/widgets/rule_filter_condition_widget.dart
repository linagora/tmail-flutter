import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:core/presentation/resources/image_paths.dart';

class RuleFilterConditionWidget extends StatelessWidget {
  final RuleFilterConditionScreenType? ruleFilterConditionScreenType;
  final RuleCondition ruleCondition;
  final Function(Field?)? tapRuleConditionFieldCallback;
  final Function(Comparator?)? tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final TextEditingController? conditionValueEditingController;
  final FocusNode? conditionValueFocusNode;
  final OnChangeFilterInputAction? conditionValueOnChangeAction;
  final ImagePaths? imagePaths;
  final Function()? tapRemoveRuleFilterConditionCallback;

  const RuleFilterConditionWidget({
    super.key,
    this.ruleFilterConditionScreenType,
    required this.ruleCondition,
    this.tapRuleConditionFieldCallback,
    this.tapRuleConditionComparatorCallback,
    this.conditionValueErrorText,
    this.conditionValueEditingController,
    this.conditionValueFocusNode,
    this.conditionValueOnChangeAction,
    this.imagePaths,
    this.tapRemoveRuleFilterConditionCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: ruleFilterConditionScreenType == RuleFilterConditionScreenType.mobile ? true : false,
      endActionPane: ActionPane(
        extentRatio: 0.1,
        motion: const BehindMotion(),
        children: [
          CustomSlidableAction(
            padding: const EdgeInsets.only(right: 12),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
            onPressed: (_) => tapRemoveRuleFilterConditionCallback!(),
            backgroundColor: AppColor.colorBackgroundFieldConditionRulesFilter,
            child: CircleAvatar(
              backgroundColor: AppColor.colorRemoveRuleFilterConditionButton,
              radius: 110,
              child: SvgPicture.asset(
                imagePaths!.icMinimize,
                fit: BoxFit.fill,
                colorFilter: AppColor.colorDeletePermanentlyButton.asFilter(),
              ),
            )
          )
        ]
      ),
      child: Builder(builder: (context) {
        SlidableController? slideController = Slidable.of(context);
        return ValueListenableBuilder<int>(
          valueListenable: slideController?.direction ?? ValueNotifier<int>(0),
          builder: (context, value, _) {
            var borderRadius = value != -1 ? 
              BorderRadius.circular(12) : 
              const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                topLeft: Radius.circular(12)
              );
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.colorBackgroundFieldConditionRulesFilter,
                borderRadius: borderRadius,
              ),
              child: RuleFilterConditionRow(
                ruleFilterConditionScreenType: ruleFilterConditionScreenType,
                ruleCondition: ruleCondition,
                tapRuleConditionFieldCallback: tapRuleConditionFieldCallback,
                tapRuleConditionComparatorCallback: tapRuleConditionComparatorCallback,
                conditionValueErrorText: conditionValueErrorText,
                conditionValueEditingController: conditionValueEditingController,
                conditionValueFocusNode: conditionValueFocusNode,
                conditionValueOnChangeAction: conditionValueOnChangeAction,
                tapRemoveRuleFilterConditionCallback: tapRemoveRuleFilterConditionCallback,
                imagePaths: imagePaths,
              )
            );
          }
        );
      })
    );
    
  }
}