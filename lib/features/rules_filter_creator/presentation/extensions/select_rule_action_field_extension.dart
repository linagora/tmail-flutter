import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_condition_combiner_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_condition_comparator_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_condition_field_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_condition_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SelectRuleActionFieldExtension on RulesFilterCreatorController {
  void unFocusAllInputField() {
    inputRuleNameFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void selectRuleConditionCombinerAction(
    BuildContext context,
    ConditionCombiner conditionCombiner,
  ) {
    unFocusAllInputField();

    final contextMenuActions = ConditionCombiner.values.map((filter) {
      return ContextItemConditionCombinerAction(
        filter,
        conditionCombiner,
        AppLocalizations.of(context),
        imagePaths,
      );
    }).toList();

    openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        selectConditionCombiner(menuAction.action);
      },
    );
  }

  void selectRuleConditionFieldAction(
    BuildContext context,
    Field? currentField,
    Field selectedField,
    RuleFilterConditionScreenType screenType,
    int index,
  ) {
    if (screenType == RuleFilterConditionScreenType.mobile) {
      unFocusAllInputField();

      final contextMenuActions = Field.values.map((field) {
        return ContextItemRuleConditionFieldAction(
          field,
          selectedField,
          AppLocalizations.of(context),
          imagePaths,
        );
      }).toList();

      openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          popBack();
          updateRuleConditionField(menuAction.action, index);
        },
      );
    } else {
      updateRuleConditionField(currentField, index);
    }
  }

  void selectRuleConditionComparatorAction(
    BuildContext context,
    Comparator? currentComparator,
    Comparator selectedComparator,
    RuleFilterConditionScreenType screenType,
    int index,
  ) {
    if (screenType == RuleFilterConditionScreenType.mobile) {
      unFocusAllInputField();

      final contextMenuActions = Comparator.values.map((comparator) {
        return ContextItemRuleConditionComparatorAction(
          comparator,
          selectedComparator,
          AppLocalizations.of(context),
          imagePaths,
        );
      }).toList();

      openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          popBack();
          updateRuleConditionComparator(menuAction.action, index);
        },
      );
    } else {
      updateRuleConditionComparator(currentComparator, index);
    }
  }

  void selectRuleFilterAction(
    BuildContext context,
    EmailRuleFilterAction? selectedFilterAction,
    int index,
  ) {
    final contextMenuActions = EmailRuleFilterAction.values.map((filterAction) {
      if (filterAction.isSupported) {
        return ContextItemRuleFilterAction(
          filterAction,
          selectedFilterAction,
          AppLocalizations.of(context),
          imagePaths,
        );
      } else {
        return null;
      }
    }).nonNulls.toList();

    if (contextMenuActions.isEmpty) return;

    unFocusAllInputField();

    openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        if (menuAction.action !=
            listEmailRuleFilterActionSelected[index].action) {
          updateEmailRuleFilterAction(context, menuAction.action, index);
        }
      },
    );
  }
}