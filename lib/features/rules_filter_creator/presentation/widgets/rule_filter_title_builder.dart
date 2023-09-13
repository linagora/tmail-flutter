import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_condition_combiner.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapActionCallback<RuleConditionCombiner> = Function(RuleConditionCombiner? value);

class RuleFilterTitle extends StatelessWidget {

  final ConditionCombiner? conditionCombinerType;
  final OnTapActionCallback? tapActionCallback;
  final RuleFilterConditionScreenType ruleFilterConditionScreenType;

  const RuleFilterTitle({
    Key? key,
    this.conditionCombinerType,
    this.tapActionCallback,
    required this.ruleFilterConditionScreenType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conditionTitle = AppLocalizations.of(context).conditionTitleRulesFilter;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          conditionTitle.substring(0, 2),
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black
          )
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          width: 150,
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
        Text(
          conditionTitle.substring(6),
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black
          )
        )
      ]
    );
  }
}
