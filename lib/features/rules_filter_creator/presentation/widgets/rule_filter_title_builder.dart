import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterTitle extends StatelessWidget {
  final ImagePaths imagePaths;
  final ConditionCombiner? conditionCombinerType;
  final OnRuleTapActionCallback onTapActionCallback;
  final bool isMobile;

  const RuleFilterTitle({
    Key? key,
    required this.imagePaths,
    required this.isMobile,
    required this.conditionCombinerType,
    required this.onTapActionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final titleBeforeWidget = Text(
      appLocalizations.conditionTitleRulesFilterBeforeCombiner,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 14,
        height: 18 / 14,
        color: Colors.black,
      ),
    );

    final titleAfterWidget = Text(
      appLocalizations.conditionTitleRulesFilterAfterCombiner,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 14,
        height: 18 / 14,
        color: Colors.black,
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              titleBeforeWidget,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  constraints: const BoxConstraints(minWidth: 100),
                  child: RuleFilterButtonField<ConditionCombiner>(
                    value: conditionCombinerType,
                    imagePaths: imagePaths,
                    onTapActionCallback: onTapActionCallback,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          titleAfterWidget,
        ],
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      runSpacing: 8,
      children: [
        titleBeforeWidget,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          width: 158,
          child: DropDownButtonWidget<ConditionCombiner>(
            items: ConditionCombiner.values,
            itemSelected: conditionCombinerType,
            supportSelectionIcon: true,
            heightItem: 40,
            labelTextStyle: ThemeUtils.textStyleBodyBody3(
              color: Colors.black,
            ),
            hintTextStyle: ThemeUtils.textStyleBodyBody3(
              color: AppColor.steelGray400,
            ),
            onChanged: onTapActionCallback,
          ),
        ),
        titleAfterWidget,
      ],
    );
  }
}
