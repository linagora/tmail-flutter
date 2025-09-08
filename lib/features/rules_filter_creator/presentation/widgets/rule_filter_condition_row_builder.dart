import 'package:core/core.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterConditionRow extends StatelessWidget {
  final RuleFilterConditionScreenType? ruleFilterConditionScreenType;
  final RuleCondition ruleCondition;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final Function(Field?)? tapRuleConditionFieldCallback;
  final Function(Comparator?)? tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final TextEditingController textEditingController;
  final FocusNode? conditionValueFocusNode;
  final OnChangeFilterInputAction? conditionValueOnChangeAction;

  const RuleFilterConditionRow({
    Key? key,
    required this.ruleFilterConditionScreenType,
    required this.ruleCondition,
    required this.imagePaths,
    required this.textEditingController,
    required this.onDeleteRuleConditionAction,
    this.tapRuleConditionFieldCallback,
    this.tapRuleConditionComparatorCallback,
    this.conditionValueErrorText,
    this.conditionValueFocusNode,
    this.conditionValueOnChangeAction,
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
              editingController: textEditingController,
            ),
          ],
        );
      case RuleFilterConditionScreenType.tablet:
      case RuleFilterConditionScreenType.desktop:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: DropDownButtonWidget<rule_condition.Field>(
                items: rule_condition.Field.values,
                itemSelected: ruleCondition.field,
                dropdownMaxHeight: 250,
                heightItem: 40,
                labelTextStyle: ThemeUtils.textStyleBodyBody3(
                  color: Colors.black,
                ),
                hintTextStyle: ThemeUtils.textStyleBodyBody3(
                  color: AppColor.steelGray400,
                ),
                onChanged: (newField) => {
                  tapRuleConditionFieldCallback!(newField)
                },
                supportSelectionIcon: true,
              )
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropDownButtonWidget<rule_condition.Comparator>(
                items: rule_condition.Comparator.values,
                itemSelected: ruleCondition.comparator,
                heightItem: 40,
                labelTextStyle: ThemeUtils.textStyleBodyBody3(
                  color: Colors.black,
                ),
                hintTextStyle: ThemeUtils.textStyleBodyBody3(
                  color: AppColor.steelGray400,
                ),
                onChanged: (newComparator) => {
                  tapRuleConditionComparatorCallback!(newComparator)
                },
                supportSelectionIcon: true,
              )
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DefaultInputFieldWidget(
                hintText: AppLocalizations.of(context).conditionValueHintTextInput,
                errorText: conditionValueErrorText,
                focusNode: conditionValueFocusNode,
                inputColor: Colors.black,
                onTextChange: conditionValueOnChangeAction,
                textEditingController: textEditingController,
              ),
            ),
            RuleFilterDeleteButtonWidget(
              imagePaths: imagePaths,
              margin: const EdgeInsetsDirectional.only(top: 2),
              onDeleteRuleConditionAction: onDeleteRuleConditionAction,
            ),
          ],
        );
      default:
          return const SizedBox.shrink();
    }
  }
}
