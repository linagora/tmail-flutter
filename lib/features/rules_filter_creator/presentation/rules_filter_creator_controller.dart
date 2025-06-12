import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/list_rule_filter_action_argument_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_input_field_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RulesFilterCreatorController extends BaseMailboxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  GetAllRulesInteractor? _getAllRulesInteractor;

  final errorRuleName = Rxn<String>();
  final emailRuleFilterActionSelected = Rxn<EmailRuleFilterAction>();
  final mailboxSelected = Rxn<PresentationMailbox>();
  final actionType = CreatorActionType.create.obs;
  final listRuleCondition = RxList<RuleCondition>();

  final TextEditingController inputRuleNameController = TextEditingController();
  final FocusNode inputRuleNameFocusNode = FocusNode();
  final listRuleConditionValueArguments = RxList<RulesFilterInputFieldArguments>();
  final conditionCombinerType = Rxn<ConditionCombiner>();

  final errorMailboxSelectedValue = Rxn<String>();
  final errorForwardEmailValue = Rxn<String>();
  final TextEditingController forwardEmailController = TextEditingController();
  final FocusNode forwardEmailFocusNode = FocusNode();
  final listEmailRuleFilterActionSelected = RxList<RuleFilterActionArguments>();
  int maxCountAction = EmailRuleFilterAction.values.where((action) => action.isSupported).length - 1;
  final isShowAddAction = Rxn<bool>();

  String? _newRuleName;

  RulesFilterCreatorArguments? arguments;
  AccountId? _accountId;
  Session? _session;
  TMailRule? _currentTMailRule;
  EmailAddress? _emailAddress;
  List<TMailRule>? _listEmailRule;
  PresentationMailbox? _mailboxDestination;

  RulesFilterCreatorController(
    this._getAllMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
  ) : super(treeBuilder, verifyNameInteractor);

  @override
  void onInit() {
    super.onInit();
    arguments = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _session = arguments!.session;
      _currentTMailRule = arguments!.tMailRule;
      _emailAddress = arguments!.emailAddress;
      _mailboxDestination = arguments!.mailboxDestination;
      actionType.value = arguments!.actionType;
      injectRuleFilterBindings(_session, _accountId);
      _setUpDefaultValueRuleFilter();
      _getAllRules();
      _getAllMailboxAction();
    }
  }

  @override
  void onClose() {
    inputRuleNameFocusNode.dispose();
    inputRuleNameController.dispose();
    for (var ruleConditionValueArguments in listRuleConditionValueArguments) {
      ruleConditionValueArguments.focusNode.dispose();
      ruleConditionValueArguments.controller.dispose();
    }
    forwardEmailFocusNode.dispose();
    forwardEmailController.dispose();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess) {
      await buildTree(success.mailboxList);
      if (currentContext != null) {
        syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is GetAllRulesSuccess) {
      log('RulesFilterCreatorController::handleSuccessViewState():GetAllRulesSuccess: ${success.rules}');
      if (success.rules?.isNotEmpty == true) {
        _listEmailRule = success.rules!;
      }
    }
  }

  @override
  void onDone() {
    viewState.value.fold((failure) => null, (success) {
      if (success is GetAllMailboxSuccess) {
        _setUpRuleFilterActions();
      }
    });
  }

  void _getAllRules() {
    _getAllRulesInteractor = getBinding<GetAllRulesInteractor>();

    if (_accountId != null && _getAllRulesInteractor != null) {
      consumeState(_getAllRulesInteractor!.execute(_accountId!));
    }
  }

  void _setUpDefaultValueRuleFilter() {
    conditionCombinerType.value = ConditionCombiner.AND;
    switch(actionType.value) {
      case CreatorActionType.create:
        RuleCondition newRuleCondition = RuleCondition(
          field: rule_condition.Field.from,
          comparator: rule_condition.Comparator.contains,
          value: ''
        );
        listRuleCondition.add(newRuleCondition);
        RulesFilterInputFieldArguments newRuleConditionValueArguments = RulesFilterInputFieldArguments(
          focusNode: FocusNode(),
          errorText: '',
          controller: TextEditingController(),
        );
        listRuleConditionValueArguments.add(newRuleConditionValueArguments);
        isShowAddAction.value = true;
        if (_emailAddress != null) {
          RuleCondition firstRuleCondition = RuleCondition(
            field: rule_condition.Field.from,
            comparator: rule_condition.Comparator.contains,
            value: _emailAddress!.email!,
          );
          listRuleCondition[0] = firstRuleCondition;
          listRuleCondition.refresh();
          _setValueInputField(
            listRuleConditionValueArguments[0].controller,
            listRuleCondition[0].value
          );
        }
        if (_mailboxDestination != null) {
          if (_mailboxDestination!.isSpam) {
            listEmailRuleFilterActionSelected.add(MarkAsSpamActionArguments());
          } else {
            mailboxSelected.value = _mailboxDestination;
            listEmailRuleFilterActionSelected.add(
              MoveMessageActionArguments(mailbox: _mailboxDestination)
            );
          }
        } else {
          listEmailRuleFilterActionSelected.add(RuleFilterActionArguments.emptyAction());
        }
        break;
      case CreatorActionType.edit:
        if (_currentTMailRule == null) {
          return;
        }

        if (_currentTMailRule!.conditionGroup?.conditions.isNotEmpty == true) {
          for (var condition in _currentTMailRule!.conditionGroup!.conditions) {
            listRuleCondition.add(condition);
            RulesFilterInputFieldArguments newRuleConditionValueArguments = RulesFilterInputFieldArguments(
              focusNode: FocusNode(),
              errorText: '',
              controller: TextEditingController(),
            );
            listRuleConditionValueArguments.add(newRuleConditionValueArguments);
            _setValueInputField(
              newRuleConditionValueArguments.controller,
              condition.value
            );
          }
        }

        conditionCombinerType.value = _currentTMailRule!.conditionGroup?.conditionCombiner;

        if (_currentTMailRule!.action.reject == true) {
          EmailRuleFilterAction? action = EmailRuleFilterAction.rejectIt;
          listEmailRuleFilterActionSelected.add(RuleFilterActionArguments.newAction(action));
        }

        if (_currentTMailRule!.action.markAsImportant == true) {
          EmailRuleFilterAction? action = EmailRuleFilterAction.starIt;
          listEmailRuleFilterActionSelected.add(RuleFilterActionArguments.newAction(action));
        }

        if (_currentTMailRule!.action.markAsSeen == true) {
          EmailRuleFilterAction? action = EmailRuleFilterAction.maskAsSeen;
          listEmailRuleFilterActionSelected.add(RuleFilterActionArguments.newAction(action));
        }

        if (listEmailRuleFilterActionSelected.length >= maxCountAction) {
          isShowAddAction.value = false;
        } else {
          isShowAddAction.value = true;
        }

        _newRuleName = _currentTMailRule!.name;
        _setValueInputField(inputRuleNameController, _newRuleName ?? '');
        break;
    }
    inputRuleNameFocusNode.requestFocus();
  }

  MailboxId? getSpamMailboxId() {
    return findMailboxNodeByRole(PresentationMailbox.roleJunk)?.item.id
      ?? findMailboxNodeByRole(PresentationMailbox.roleSpam)?.item.id;
  }

  void _setValueInputField(TextEditingController? controller, String value) {
    controller?.value = controller.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length));
  }

  void _setUpRuleFilterActions() {
    if (_currentTMailRule?.action.appendIn.mailboxIds.isNotEmpty != true) return;

    final mailboxNode = findMailboxNodeById(
      _currentTMailRule!.action.appendIn.mailboxIds.first);

    if (mailboxNode == null) {
      mailboxSelected.value = PresentationMailbox.unifiedMailbox;
      listEmailRuleFilterActionSelected.add(
        MoveMessageActionArguments(mailbox: PresentationMailbox.unifiedMailbox));
    } else if (mailboxNode.item.isSpam) {
      listEmailRuleFilterActionSelected.add(MarkAsSpamActionArguments());
    } else {
      mailboxSelected.value = mailboxNode.item;
      listEmailRuleFilterActionSelected.add(
        MoveMessageActionArguments(mailbox: mailboxNode.item));
    }
  }

  void _getAllMailboxAction() {
    if (_accountId != null && _session != null) {
      consumeState(_getAllMailboxInteractor.execute(_session!, _accountId!));
    }
  }

  void updateRuleName(BuildContext context, String? value) {
    _newRuleName = value;
    errorRuleName.value = _getErrorStringByInputValue(context, _newRuleName);
  }

  void updateConditionValue(BuildContext context, String? value, int ruleConditionIndex) {
    RuleCondition newRuleCondition = RuleCondition(
      field: listRuleCondition[ruleConditionIndex].field,
      comparator: listRuleCondition[ruleConditionIndex].comparator,
      value: value!,
    );
    listRuleCondition[ruleConditionIndex] = newRuleCondition;
    listRuleCondition.refresh();
    String? errorString = _getErrorStringByInputValue(context, listRuleCondition[ruleConditionIndex].value);
    RulesFilterInputFieldArguments newRuleConditionValueArguments = RulesFilterInputFieldArguments(
      focusNode: listRuleConditionValueArguments[ruleConditionIndex].focusNode,
      errorText: errorString ?? '',
      controller: listRuleConditionValueArguments[ruleConditionIndex].controller,
    );
    if (listRuleConditionValueArguments.length > ruleConditionIndex) {
      listRuleConditionValueArguments[ruleConditionIndex] = newRuleConditionValueArguments;
    } else {
      listRuleConditionValueArguments.add(newRuleConditionValueArguments);
    }
    listRuleConditionValueArguments.refresh();
  }

  String? _getErrorStringByInputValue(BuildContext context, String? inputValue) {
    return verifyNameInteractor.execute(
      inputValue,
      [
        EmptyNameValidator(),
        NameWithSpaceOnlyValidator(),
      ],
    ).fold(
      (failure) {
          if (failure is VerifyNameFailure) {
            return failure.getMessageRulesFilter(context);
          } else {
            return null;
          }
        },
      (success) => null
    );
  }

  void updateRuleConditionField(rule_condition.Field? newField, int? ruleConditionIndex) {
    if (newField != null && ruleConditionIndex != null) {
      RuleCondition newRuleCondition = RuleCondition(
        field: newField,
        comparator: listRuleCondition[ruleConditionIndex].comparator,
        value: listRuleCondition[ruleConditionIndex].value,
      );
      listRuleCondition[ruleConditionIndex] = newRuleCondition;
      listRuleCondition.refresh();
    }
  }

  void updateRuleConditionComparator(rule_condition.Comparator? newComparator, int? ruleConditionIndex) {
    if (newComparator != null && ruleConditionIndex != null) {
      RuleCondition newRuleCondition = RuleCondition(
        field: listRuleCondition[ruleConditionIndex].field,
        comparator: newComparator,
        value: listRuleCondition[ruleConditionIndex].value,
      );
      listRuleCondition[ruleConditionIndex] = newRuleCondition;
      listRuleCondition.refresh();
    }
  }

  void updateEmailRuleFilterAction(
    BuildContext context,
    EmailRuleFilterAction? newAction,
    int ruleFilterActionIndex
  ) {
    RuleFilterActionArguments newRuleFilterAction = RuleFilterActionArguments.newAction(newAction);
    if (newRuleFilterAction is RejectItActionArguments) {
      listEmailRuleFilterActionSelected.clear();
      forwardEmailController.clear();
      mailboxSelected.value = null;
      listEmailRuleFilterActionSelected.add(newRuleFilterAction);
      isShowAddAction.value = false;
      errorForwardEmailValue.value = null;
      errorMailboxSelectedValue.value = null;
    } else {
      if (listEmailRuleFilterActionSelected.length < maxCountAction) {
        isShowAddAction.value = true;
      }
      final int duplicatedIndex = listEmailRuleFilterActionSelected.indexWhere((filterAction) => filterAction.action == newAction);
      if (duplicatedIndex != -1) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).duplicatedActionError,
        );
        return;
      }

      if (newAction == EmailRuleFilterAction.markAsSpam) {
        final moveMessageActionIndex = listEmailRuleFilterActionSelected
          .indexWhere((filter) => filter.action == EmailRuleFilterAction.moveMessage);
        log('RulesFilterCreatorController::selectEmailRuleFilterAction: moveMessageActionIndex = $moveMessageActionIndex');
        if (moveMessageActionIndex != -1) {
          mailboxSelected.value = null;
          listEmailRuleFilterActionSelected[ruleFilterActionIndex] = newRuleFilterAction;
          if (listEmailRuleFilterActionSelected.length > 1) {
            listEmailRuleFilterActionSelected.removeAt(moveMessageActionIndex);
          }
          isShowAddAction.value = listEmailRuleFilterActionSelected.length < maxCountAction;
          listEmailRuleFilterActionSelected.refresh();
          return;
        }
      }

      if (newAction == EmailRuleFilterAction.moveMessage) {
        final markAsSpamActionIndex = listEmailRuleFilterActionSelected
          .indexWhere((filter) => filter.action == EmailRuleFilterAction.markAsSpam);
        log('RulesFilterCreatorController::selectEmailRuleFilterAction: markAsSpamActionIndex = $markAsSpamActionIndex');
        if (markAsSpamActionIndex != -1) {
          listEmailRuleFilterActionSelected[ruleFilterActionIndex] = newRuleFilterAction;
          if (listEmailRuleFilterActionSelected.length > 1) {
            listEmailRuleFilterActionSelected.removeAt(markAsSpamActionIndex);
          }
          isShowAddAction.value = listEmailRuleFilterActionSelected.length < maxCountAction;
          listEmailRuleFilterActionSelected.refresh();
          return;
        }
      }

      listEmailRuleFilterActionSelected[ruleFilterActionIndex] = newRuleFilterAction;
      listEmailRuleFilterActionSelected.refresh();
    }
  }

  void selectMailbox(BuildContext context, int ruleFilterActionIndex) async {
    if (_accountId != null) {
      final arguments = DestinationPickerArguments(
        _accountId!,
        MailboxActions.selectForRuleAction,
        _session);

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox is PresentationMailbox && context.mounted) {
        mailboxSelected.value = destinationMailbox;
        errorMailboxSelectedValue.value = _getErrorStringByInputValue(
          context,
          mailboxSelected.value?.getDisplayName(context));
        RuleFilterActionArguments newRuleFilterAction = MoveMessageActionArguments(mailbox: mailboxSelected.value);
        listEmailRuleFilterActionSelected[ruleFilterActionIndex] = newRuleFilterAction;
      }
    }
  }

  void createNewRuleFilter(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);

    final errorName = _getErrorStringByInputValue(context, _newRuleName);
    log('RulesFilterCreatorController::createNewRuleFilter:errorName: $errorName');
    if (errorName?.isNotEmpty == true) {
      errorRuleName.value = errorName;
      inputRuleNameFocusNode.requestFocus();
      return;
    }

    if (listRuleCondition.isEmpty
        && currentOverlayContext != null
        && currentContext != null
    ) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).youHaveNotAddedConditionToRule);
      return;
    }

    for (var ruleCondition in listRuleCondition) {
      final errorConditionString = _getErrorStringByInputValue(context, ruleCondition.value);
      log('RulesFilterCreatorController::createNewRuleFilter:errorConditionString: $errorConditionString');
      if (errorConditionString != null) {
        int ruleConditionIndex = listRuleCondition.indexOf(ruleCondition);
        RulesFilterInputFieldArguments newRuleConditionValueArguments = RulesFilterInputFieldArguments(
          focusNode: listRuleConditionValueArguments[ruleConditionIndex].focusNode,
          errorText: errorConditionString,
          controller: listRuleConditionValueArguments[ruleConditionIndex].controller,
        );
        listRuleConditionValueArguments[ruleConditionIndex] = newRuleConditionValueArguments;
        listRuleConditionValueArguments[listRuleCondition.indexOf(ruleCondition)].focusNode.requestFocus();
        return;
      }
    }

    if (listEmailRuleFilterActionSelected.isEmpty
        && currentOverlayContext != null
        && currentContext != null
    ) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).youHaveNotAddedActionToRule);
      return;
    }

    if (listEmailRuleFilterActionSelected.isEmptySelectedRuleAction()
        && currentOverlayContext != null
        && currentContext != null
    ) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).youHaveNotSelectedAnyActionForRule);
      return;
    }

    for (var ruleFilterAction in listEmailRuleFilterActionSelected) {
      if (ruleFilterAction is MoveMessageActionArguments) {
        final errorAction = _getErrorStringByInputValue(context, mailboxSelected.value?.getDisplayName(context));
        log('RulesFilterCreatorController::createNewRuleFilter:errorAction: $errorAction');
        if (errorAction?.isNotEmpty == true) {
          appToast.showToastErrorMessage(
            context,
            AppLocalizations.of(context).notSelectedMailboxToMoveMessage);
          return;
        }
      }
      if (ruleFilterAction is MarkAsSpamActionArguments) {
        final spamMailboxId = getSpamMailboxId();
        log('RulesFilterCreatorController::createNewRuleFilter:spamMailboxId: ${spamMailboxId?.asString}');
        if (spamMailboxId == null) {
          appToast.showToastErrorMessage(
            context,
            AppLocalizations.of(context).spamFolderNotFound);
          return;
        }
      }
      if (ruleFilterAction is ForwardActionArguments) {
        final errorAction = _getErrorStringByInputValue(context, ruleFilterAction.forwardEmail);
        log('RulesFilterCreatorController::createNewRuleFilter:errorAction: $errorAction');
        if (errorAction?.isNotEmpty == true) {
          errorForwardEmailValue.value = errorAction;
          forwardEmailFocusNode.requestFocus();
          return;
        }
      }
    }

    late EquatableMixin ruleFilterRequest;

    List<MailboxId> mailboxIds = [];
    bool markAsSeen = false;
    bool markAsImportant = false;
    bool reject = false;

    for (var ruleFilterAction in listEmailRuleFilterActionSelected) {
      if (ruleFilterAction is MoveMessageActionArguments) {
        mailboxIds.add(ruleFilterAction.mailbox!.id);
      }
      if (ruleFilterAction is MarkAsSpamActionArguments) {
        final spamMailboxId = getSpamMailboxId();
        if (spamMailboxId != null) {
          mailboxIds.add(spamMailboxId);
        }
      }
      if (ruleFilterAction is MarkAsSeenActionArguments) {
        markAsSeen = true;
      }
      if (ruleFilterAction is StarItActionArguments) {
        markAsImportant = true;
      }
      if (ruleFilterAction is RejectItActionArguments) {
        reject = true;
        markAsSeen = false;
        markAsImportant = false;
      }
    }

    if (actionType.value == CreatorActionType.create) {
      final newTMailRule = TMailRule(
        id: _currentTMailRule?.id,
        name: _newRuleName!,
        action: RuleAction(
          appendIn: RuleAppendIn(
            mailboxIds: mailboxIds
          ),
          markAsSeen: markAsSeen,
          markAsImportant: markAsImportant,
          reject: reject,
        ),
        conditionGroup: RuleConditionGroup(
          conditionCombiner: conditionCombinerType.value!,
          conditions: listRuleCondition,
        )
      );
      ruleFilterRequest = CreateNewEmailRuleFilterRequest(_listEmailRule ?? [], newTMailRule);
    } else {
      final newTMailRule = TMailRule(
        id: _currentTMailRule?.id,
        name: _newRuleName!,
        action: RuleAction(
          appendIn: RuleAppendIn(
            mailboxIds: mailboxIds
          ),
          markAsSeen: markAsSeen,
          markAsImportant: markAsImportant,
          reject: reject,
        ),
        conditionGroup: RuleConditionGroup(
          conditionCombiner: conditionCombinerType.value!,
          conditions: listRuleCondition,
        ));
      ruleFilterRequest = EditEmailRuleFilterRequest(_listEmailRule?.withIds ?? [], newTMailRule);
    }
    popBack(result: ruleFilterRequest);
  }

  void closeView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }

  void tapAddCondition() {
    RuleCondition newRuleCondition = RuleCondition(
      field: rule_condition.Field.from,
      comparator: rule_condition.Comparator.contains,
      value: ''
    );
    listRuleCondition.add(newRuleCondition);
    listRuleConditionValueArguments.add(RulesFilterInputFieldArguments(
      focusNode: FocusNode(),
      errorText: '',
      controller: TextEditingController(),
    ));
  }

  void tapRemoveCondition(int ruleConditionIndex) {
    listRuleCondition.removeAt(ruleConditionIndex);
    listRuleConditionValueArguments.removeAt(ruleConditionIndex);
  }

  void selectConditionCombiner(ConditionCombiner? combinerType) {
    if (combinerType != null) {
      conditionCombinerType.value = combinerType;
    }
  }

  void tapAddAction() {
    listEmailRuleFilterActionSelected.add(RuleFilterActionArguments.emptyAction());
    if (listEmailRuleFilterActionSelected.length >= maxCountAction) {
      isShowAddAction.value = false;
    }
  }

  void tapRemoveAction(int ruleFilterActionIndex) {
    EmailRuleFilterAction? actionToRemove = listEmailRuleFilterActionSelected[ruleFilterActionIndex].action;
    if (actionToRemove is ForwardActionArguments) {
      forwardEmailController.clear();
      errorForwardEmailValue.value = null;
    }
    if (actionToRemove is MoveMessageActionArguments) {
      mailboxSelected.value = null;
      errorMailboxSelectedValue.value = null;
    }
    isShowAddAction.value = true;
    listEmailRuleFilterActionSelected.removeAt(ruleFilterActionIndex);
  }

  void updateForwardEmailValue(BuildContext context, String? value, int ruleActionIndex) {
    String? errorAction = _getErrorStringByInputValue(context, value);
    log('RulesFilterCreatorController::createNewRuleFilter:errorAction: $errorAction');
    RuleFilterActionArguments newRuleFilterAction = ForwardActionArguments(forwardEmail: value);
    errorForwardEmailValue.value = errorAction;
    listEmailRuleFilterActionSelected[ruleActionIndex] = newRuleFilterAction;
    listEmailRuleFilterActionSelected.refresh();
  }
}