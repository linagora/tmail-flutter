import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterConditionRow extends StatelessWidget {
  final bool isMobile;
  final RuleCondition ruleCondition;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final OnRuleTapActionCallback tapRuleConditionFieldCallback;
  final OnRuleTapActionCallback tapRuleConditionComparatorCallback;
  final String? conditionValueErrorText;
  final TextEditingController textEditingController;
  final FocusNode? conditionValueFocusNode;
  final OnTextChange? conditionValueOnChangeAction;

  const RuleFilterConditionRow({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RuleFilterButtonField<rule_condition.Field>(
            value: ruleCondition.field,
            imagePaths: imagePaths,
            onTapActionCallback: tapRuleConditionFieldCallback,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RuleFilterButtonField<rule_condition.Comparator>(
              value: ruleCondition.comparator,
              imagePaths: imagePaths,
              onTapActionCallback: tapRuleConditionComparatorCallback,
            ),
          ),
          DefaultInputFieldWidget(
            hintText: AppLocalizations.of(context).conditionValueHintTextInput,
            errorText: conditionValueErrorText,
            focusNode: conditionValueFocusNode,
            inputColor: Colors.black,
            onTextChange: conditionValueOnChangeAction,
            textEditingController: textEditingController,
          ),
        ],
      );
    } else {
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
              onChanged: tapRuleConditionFieldCallback,
              supportSelectionIcon: true,
            ),
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
            onChanged: tapRuleConditionComparatorCallback,
            supportSelectionIcon: true,
          )),
          const SizedBox(width: 8),
          Expanded(
            child: DefaultInputFieldWidget(
              hintText:
                  AppLocalizations.of(context).conditionValueHintTextInput,
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
    }
  }
}
