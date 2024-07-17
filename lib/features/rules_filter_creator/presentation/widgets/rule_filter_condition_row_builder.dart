import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_remove_button_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterConditionRow extends StatelessWidget {
  final RuleFilterConditionScreenType? ruleFilterConditionScreenType;
  final RuleCondition ruleCondition;
  final Function(Field?)? tapRuleConditionFieldCallback;
  final Function(Comparator?)? tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final TextEditingController? conditionValueEditingController;
  final FocusNode? conditionValueFocusNode;
  final OnChangeFilterInputAction? conditionValueOnChangeAction;
  final Function()? tapRemoveRuleFilterConditionCallback;
  final ImagePaths? imagePaths;

  const RuleFilterConditionRow({
    Key? key,
    required this.ruleFilterConditionScreenType,
    required this.ruleCondition,
    this.tapRuleConditionFieldCallback,
    this.tapRuleConditionComparatorCallback,
    this.conditionValueErrorText,
    this.conditionValueEditingController,
    this.conditionValueFocusNode,
    this.conditionValueOnChangeAction,
    this.tapRemoveRuleFilterConditionCallback,
    this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (ruleFilterConditionScreenType) {
    case RuleFilterConditionScreenType.mobile: 
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RuleFilterButtonField<rule_condition.Field>(
            value: ruleCondition.field,
            tapActionCallback: (value) {
              KeyboardUtils.hideKeyboard(context);
              tapRuleConditionFieldCallback!(ruleCondition.field);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: RuleFilterButtonField<rule_condition.Comparator>(
              value: ruleCondition.comparator,
              tapActionCallback: (value) {
                KeyboardUtils.hideKeyboard(context);
                tapRuleConditionComparatorCallback!(ruleCondition.comparator);
              },
            )
          ),
          RulesFilterInputField(
            hintText: AppLocalizations.of(context).conditionValueHintTextInput,
            errorText: conditionValueErrorText,
            focusNode: conditionValueFocusNode,
            onChangeAction: conditionValueOnChangeAction,
            editingController: conditionValueEditingController,
          ),
        ],
      );
      case RuleFilterConditionScreenType.tablet:
      case RuleFilterConditionScreenType.desktop:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropDownButtonWidget<rule_condition.Field>(
                items: rule_condition.Field.values,
                itemSelected: ruleCondition.field,
                dropdownMaxHeight: 250,
                onChanged: (newField) => {
                  tapRuleConditionFieldCallback!(newField)
                },
                supportSelectionIcon: true,
              )
            ),
            Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropDownButtonWidget<rule_condition.Comparator>(
                items: rule_condition.Comparator.values,
                itemSelected: ruleCondition.comparator,
                onChanged: (newComparator) => {
                  tapRuleConditionComparatorCallback!(newComparator)
                },
                supportSelectionIcon: true,
              )
            ),
            Expanded(
              child: RulesFilterInputField(
                hintText: AppLocalizations.of(context).conditionValueHintTextInput,
                errorText: conditionValueErrorText,
                focusNode: conditionValueFocusNode,
                onChangeAction: conditionValueOnChangeAction,
                editingController: conditionValueEditingController,
                )
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(start: 12),
              alignment: Alignment.center,
              child: RuleFilterConditionRemoveButton(
                tapRemoveRuleFilterConditionCallback: tapRemoveRuleFilterConditionCallback,
                imagePath: imagePaths,
              )
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
