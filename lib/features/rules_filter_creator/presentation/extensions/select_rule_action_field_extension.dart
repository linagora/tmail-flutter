import 'package:flutter/material.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_condition_combiner_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_condition_comparator_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_condition_field_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/context_menu/context_item_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
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
        updateConditionCombiner(menuAction.action);
      },
    );
  }

  void selectRuleConditionFieldAction(
    BuildContext context,
    Field? currentField,
    Field selectedField,
    bool isMobile,
    int index,
  ) {
    if (isMobile) {
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
    bool isMobile,
    int index,
  ) {
    if (isMobile) {
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
      if (filterAction.isSupported(isLabelAvailable: isLabelAvailable)) {
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

  void onSelectRuleAction({
    required AppLocalizations appLocalizations,
    required int actionIndex,
    required EmailRuleFilterAction filerAction,
  }) {
    switch (filerAction) {
      case EmailRuleFilterAction.moveMessage:
        selectMailbox(appLocalizations, actionIndex);
        break;
      case EmailRuleFilterAction.labelMessage:
        _selectLabel(appLocalizations, actionIndex);
        break;
      default:
        break;
    }
  }

  Future<void> _selectLabel(
    AppLocalizations appLocalizations,
    int actionIndex,
  ) async {
    await openChooseLabelModal(
      labels: allLabels,
      imagePaths: imagePaths,
      onSelectLabelsAction: (labels) =>
        _addLabelMessageActionToRuleFilterAction(
          appLocalizations,
          actionIndex,
          labels,
        ),
      onCreateALabelAction: () => createNewLabelWithResultAction(
        allLabels: allLabels,
        imagePaths: imagePaths,
        accountId: accountId,
        verifyNameInteractor: verifyNameInteractor,
        createNewLabelInteractor: arguments?.createNewLabelInteractor,
        editLabelInteractor: arguments?.editLabelInteractor,
      ),
    );
  }

  void _addLabelMessageActionToRuleFilterAction(
    AppLocalizations appLocalizations,
    int actionIndex,
    List<Label> selectedLabels,
  ) {
    errorMessageValue.value = getErrorStringByInputValue(
      appLocalizations,
      selectedLabels.displayNameAsString,
    );
    listEmailRuleFilterActionSelected[actionIndex] =
        LabelMessageActionArguments(labels: selectedLabels);
  }
}