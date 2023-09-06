import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
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
              child: _buildRuleFilterCondition(
                context,
                ruleFilterConditionScreenType,
                ruleCondition,
                tapRuleConditionFieldCallback,
                tapRuleConditionComparatorCallback,
                conditionValueErrorText,
                conditionValueEditingController,
                conditionValueFocusNode,
                conditionValueOnChangeAction,
                tapRemoveRuleFilterConditionCallback,
                imagePaths,
              )
            );
          }
        );
      })
    );
    
  }
}

Widget _buildRuleFilterCondition(
  BuildContext context,
  RuleFilterConditionScreenType? ruleFilterConditionScreenType,
  RuleCondition ruleCondition,
  Function(Field?)? tapRuleConditionFieldCallback,
  Function(Comparator?)? tapRuleConditionComparatorCallback,
  String? conditionValueErrorText,
  TextEditingController? conditionValueEditingController,
  FocusNode? conditionValueFocusNode,
  OnChangeFilterInputAction? conditionValueOnChangeAction,
  Function()? tapRemoveRuleFilterConditionCallback,
  ImagePaths? imagePaths,
) {
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
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.center,
              child: _buildRemoveRuleFilterConditionButton(tapRemoveRuleFilterConditionCallback, imagePaths)
            ),
          ],
        );
      default:
        return Container();
    }
}

Widget _buildRemoveRuleFilterConditionButton (
  Function()? tapRemoveRuleFilterConditionCallback,
  ImagePaths? imagePath,
) {
  return InkWell(
    onTap: tapRemoveRuleFilterConditionCallback,
    child: CircleAvatar(
      backgroundColor: AppColor.colorRemoveRuleFilterConditionButton,
      radius: 22,
      child: SvgPicture.asset(
        imagePath!.icMinimize,
        fit: BoxFit.fill,
        colorFilter: AppColor.colorDeletePermanentlyButton.asFilter(),
      ),
    )
  );
}