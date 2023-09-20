import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/styles/rule_filter_title_styles.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapActionCallback<RuleConditionCombiner> = Function(ConditionCombiner? value);

class RuleFilterTitle extends StatelessWidget {

  final ConditionCombiner? conditionCombinerType;
  final OnTapActionCallback? tapActionCallback;
  final RuleFilterConditionScreenType ruleFilterConditionScreenType;

  const RuleFilterTitle({
    Key? key,
    required this.ruleFilterConditionScreenType,
    this.conditionCombinerType,
    this.tapActionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).conditionTitleRulesFilterBeforeCombiner,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          maxLines: RuleFilterTitleStyles.textMaxLines,
          style: RuleFilterTitleStyles.textStyle,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: RuleFilterTitleStyles.combinerTypeSelectionAreaPadding),
          width: RuleFilterTitleStyles.combinerTypeSelectionAreaWith,
          child: ruleFilterConditionScreenType == RuleFilterConditionScreenType.mobile 
              ? RuleFilterButtonField<ConditionCombiner>(
                value: conditionCombinerType,
                tapActionCallback: (value) {
                  KeyboardUtils.hideKeyboard(context);
                  tapActionCallback?.call(value);
                },
              )
              : DropDownButtonWidget<ConditionCombiner>(
                items: ConditionCombiner.values,
                itemSelected: conditionCombinerType,
                supportSelectionIcon: true,
                onChanged: (value) {
                  KeyboardUtils.hideKeyboard(context);
                  tapActionCallback?.call(value);
                },
              ),
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context).conditionTitleRulesFilterAfterCombiner,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: RuleFilterTitleStyles.textStyle,
          ),
        )
      ]
    );
  }
}
