import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';

typedef OnChangeFilterInputAction = Function(String? value);

class RuleFilterConditionWidget extends StatelessWidget {
  final bool isMobile;
  final RuleCondition ruleCondition;
  final TextEditingController textEditingController;
  final OnRuleTapActionCallback tapRuleConditionFieldCallback;
  final OnRuleTapActionCallback tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final FocusNode? conditionValueFocusNode;
  final OnChangeFilterInputAction? conditionValueOnChangeAction;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;

  const RuleFilterConditionWidget({
    super.key,
    required this.isMobile,
    required this.ruleCondition,
    required this.imagePaths,
    required this.textEditingController,
    required this.onDeleteRuleConditionAction,
    required this.tapRuleConditionFieldCallback,
    required this.tapRuleConditionComparatorCallback,
    this.conditionValueErrorText,
    this.conditionValueFocusNode,
    this.conditionValueOnChangeAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 8),
        child: Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.15,
            motion: const BehindMotion(),
            children: [
              CustomSlidableAction(
                padding: const EdgeInsets.only(right: 12),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                onPressed: (_) => onDeleteRuleConditionAction(),
                backgroundColor: AppColor.lightGrayF9FAFB,
                child: RuleFilterDeleteButtonWidget(
                  imagePaths: imagePaths,
                  onDeleteRuleConditionAction: onDeleteRuleConditionAction,
                ),
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              SlidableController? slideController = Slidable.of(context);
              return ValueListenableBuilder<int>(
                valueListenable: slideController?.direction ?? ValueNotifier<int>(0),
                builder: (context, value, _) {
                  final borderRadius = value != -1
                      ? BorderRadius.circular(10)
                      : const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        );
                  return Container(
                    padding: const EdgeInsetsDirectional.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.lightGrayF9FAFB,
                      borderRadius: borderRadius,
                    ),
                    alignment: Alignment.center,
                    child: RuleFilterConditionRow(
                      isMobile: isMobile,
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
                }
              );
            }
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
        margin: const EdgeInsetsDirectional.only(top: 8),
        decoration: const BoxDecoration(
          color: AppColor.lightGrayF9FAFB,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: RuleFilterConditionRow(
          isMobile: isMobile,
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
    }
  }
}