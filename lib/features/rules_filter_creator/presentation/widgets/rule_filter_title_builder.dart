import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapActionCallback<RuleConditionCombiner> = Function(
  ConditionCombiner? value,
);

class RuleFilterTitle extends StatelessWidget {
  final ConditionCombiner? conditionCombinerType;
  final OnTapActionCallback? tapActionCallback;
  final RuleFilterConditionScreenType ruleFilterConditionScreenType;
  final ResponsiveUtils responsiveUtils;

  const RuleFilterTitle({
    Key? key,
    required this.ruleFilterConditionScreenType,
    required this.responsiveUtils,
    this.conditionCombinerType,
    this.tapActionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final isMobile = responsiveUtils.isMobile(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      runSpacing: 8,
      children: [
        Text(
          appLocalizations.conditionTitleRulesFilterBeforeCombiner,
          style: ThemeUtils.textStyleInter400.copyWith(
            fontSize: 14,
            height: 18 / 14,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          width: isMobile ? double.infinity : 158,
          child: ruleFilterConditionScreenType ==
                  RuleFilterConditionScreenType.mobile
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
                  labelTextStyle: ThemeUtils.textStyleBodyBody3(
                    color: Colors.black,
                  ),
                  hintTextStyle: ThemeUtils.textStyleBodyBody3(
                    color: AppColor.steelGray400,
                  ),
                  onChanged: (value) {
                    KeyboardUtils.hideKeyboard(context);
                    tapActionCallback?.call(value);
                  },
                ),
        ),
        Text(
          appLocalizations.conditionTitleRulesFilterAfterCombiner,
          style: ThemeUtils.textStyleInter400.copyWith(
            fontSize: 14,
            height: 18 / 14,
            color: Colors.black,
          ),
        )
      ],
    );
  }
}
