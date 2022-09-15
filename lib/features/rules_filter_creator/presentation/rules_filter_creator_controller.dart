
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RulesFilterCreatorController extends BaseMailboxController {

  final _appToast = Get.find<AppToast>();

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllMailboxInteractor _getAllMailboxInteractor;

  final errorRuleName = Rxn<String>();
  final errorRuleConditionValue = Rxn<String>();
  final errorRuleActionValue = Rxn<String>();
  final ruleConditionFieldSelected = Rxn<rule_condition.Field>();
  final ruleConditionComparatorSelected = Rxn<rule_condition.Comparator>();
  final emailRuleFilterActionSelected = Rxn<EmailRuleFilterAction>();
  final mailboxSelected = Rxn<PresentationMailbox>();

  final inputRuleNameController = TextEditingController();
  final inputConditionValueController = TextEditingController();
  final inputRuleNameFocusNode = FocusNode();
  final inputRuleConditionFocusNode = FocusNode();

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _emailRulesController = Get.find<EmailRulesController>();

  late Worker rulesFilterCreatorArgumentsWorker;

  get actionType => _emailRulesController.rulesFilterCreatorArguments.value!.actionType;

  get _accountId => _emailRulesController.rulesFilterCreatorArguments.value!.accountId;

  get _currentTMailRule => _emailRulesController.rulesFilterCreatorArguments.value!.tMailRule;

  String? _newRuleName;
  String? _newRuleConditionValue;

  RulesFilterCreatorController(
    this._verifyNameInteractor,
    this._getAllMailboxInteractor,
    treeBuilder
  ) : super(treeBuilder);

  void _initWorker() {
    rulesFilterCreatorArgumentsWorker = ever(_emailRulesController.rulesFilterCreatorArguments, (rulesFilterCreatorArguments) {
      if (rulesFilterCreatorArguments is RulesFilterCreatorArguments) {
        _setUpDefaultValueRuleFilter();
      }
    });
  }

  @override
  void onInit() {
    _initWorker();
    super.onInit();
  }

  @override
  void onReady() {
    _setUpDefaultValueRuleFilter();
    super.onReady();
  }

  @override
  void onClose() {
    inputRuleNameFocusNode.dispose();
    inputRuleConditionFocusNode.dispose();
    inputRuleNameController.dispose();
    inputConditionValueController.dispose();
    super.onClose();
  }

  @override
  void onDone() {}

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(
      (failure) => null,
      (success) async {
        if (success is GetAllMailboxSuccess) {
          await buildTree(success.mailboxList);
          _setUpMailboxSelected();
        }
      });
  }

  @override
  void onError(error) {}

  void _setUpDefaultValueRuleFilter() {
    switch(actionType) {
      case CreatorActionType.create:
        ruleConditionFieldSelected.value = rule_condition.Field.from;
        ruleConditionComparatorSelected.value = rule_condition.Comparator.contains;
        emailRuleFilterActionSelected.value = EmailRuleFilterAction.moveMessage;
        break;
      case CreatorActionType.edit:
        if (_currentTMailRule != null) {
          ruleConditionFieldSelected.value = _currentTMailRule!.condition.field;
          ruleConditionComparatorSelected.value = _currentTMailRule!.condition.comparator;
          emailRuleFilterActionSelected.value = EmailRuleFilterAction.moveMessage;
          _newRuleConditionValue = _currentTMailRule!.condition.value;
          _setValueInputField(inputConditionValueController, _newRuleConditionValue ?? '');
          _newRuleName = _currentTMailRule!.name;
          _setValueInputField(inputRuleNameController, _newRuleName ?? '');
          _getAllMailboxAction();
        }
        break;
    }
    inputRuleNameFocusNode.requestFocus();
  }

  void _setValueInputField(TextEditingController controller, String value) {
    controller.value = controller.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length));
  }

  void _setUpMailboxSelected() {
    if (_currentTMailRule != null) {
      final mailboxIdOfRule = _currentTMailRule!.action.appendIn.mailboxIds.first;
      final mailboxNode = findMailboxNodeById(mailboxIdOfRule);
      mailboxSelected.value = mailboxNode?.item;
    }
  }

  void _getAllMailboxAction() {
    if (_accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(_accountId!));
    }
  }

  void updateRuleName(BuildContext context, String? value) {
    _newRuleName = value;
    errorRuleName.value = _getErrorStringByInputValue(context, _newRuleName);
  }

  void updateConditionValue(BuildContext context, String? value) {
    _newRuleConditionValue = value;
    errorRuleConditionValue.value = _getErrorStringByInputValue(context, _newRuleConditionValue);
  }

  String? _getErrorStringByInputValue(BuildContext context, String? inputValue) {
    return _verifyNameInteractor.execute(inputValue, [EmptyNameValidator()]).fold(
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

  void selectRuleConditionField(rule_condition.Field? newField) {
    ruleConditionFieldSelected.value = newField;
  }

  void selectRuleConditionComparator(rule_condition.Comparator? newComparator) {
    ruleConditionComparatorSelected.value = newComparator;
  }

  void selectEmailRuleFilterAction(EmailRuleFilterAction? newAction) {
    emailRuleFilterActionSelected.value = newAction;
  }

  void selectMailbox(BuildContext context) async {
    final destinationMailbox = await push(
        AppRoutes.DESTINATION_PICKER,
        arguments: DestinationPickerArguments(
            _accountId!,
            MailboxActions.selectForRuleAction));

    if (destinationMailbox is PresentationMailbox) {
      mailboxSelected.value = destinationMailbox;
      errorRuleActionValue.value = _getErrorStringByInputValue(
          context,
          mailboxSelected.value?.name?.name);
    }
  }

  void createNewRuleFilter(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final errorName = _getErrorStringByInputValue(context, _newRuleName);
    if (errorName?.isNotEmpty == true) {
      log('RulesFilterCreatorController::createNewRuleFilter(): errorName: $errorName');
      errorRuleName.value = errorName;
      inputRuleNameFocusNode.requestFocus();
      return;
    }

    final errorCondition = _getErrorStringByInputValue(context, _newRuleConditionValue);
    if (errorCondition?.isNotEmpty == true) {
      log('RulesFilterCreatorController::createNewRuleFilter(): errorCondition: $errorCondition');
      errorRuleConditionValue.value = errorCondition;
      inputRuleConditionFocusNode.requestFocus();
      return;
    }

    final errorAction = _getErrorStringByInputValue(context, mailboxSelected.value?.name?.name);
    if (errorAction?.isNotEmpty == true) {
      log('RulesFilterCreatorController::createNewRuleFilter(): errorAction: $errorAction');
      errorRuleActionValue.value = errorAction;
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(currentContext!).this_field_cannot_be_blank);
      return;
    }

    if (ruleConditionFieldSelected.value == null ||
        ruleConditionComparatorSelected.value == null ||
        emailRuleFilterActionSelected.value == null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(currentContext!).toastErrorMessageWhenCreateNewRule);
      return;
    }

    final newTMailRule = TMailRule(
        id: _currentTMailRule?.id,
        name: _newRuleName!,
        action: RuleAction(
          appendIn: RuleAppendIn(
            mailboxIds: [mailboxSelected.value!.id]
          )
        ),
        condition: rule_condition.RuleCondition(
          field: ruleConditionFieldSelected.value!,
          comparator: ruleConditionComparatorSelected.value!,
          value: _newRuleConditionValue!
        ));

    log('RulesFilterCreatorController::newTMailRule(): $newTMailRule');

    if(actionType == CreatorActionType.create) {
      _emailRulesController.createNewRuleFilterAction(
        _accountId,
        CreateNewEmailRuleFilterRequest(
          _emailRulesController.listEmailRule,
          newTMailRule,
        ),
      );
    } else {
      _emailRulesController.editEmailRuleFilterAction(
        _accountId,
        EditEmailRuleFilterRequest(
          _emailRulesController.listEmailRule.withIds,
          newTMailRule,
        ),
      );
    }

    _clearAll();
    if(kIsWeb) {
      _accountDashBoardController.rulesFilterCreatorIsActive.toggle();
    } else {
      popBack();
    }
  }

  void _clearAll() {
    inputRuleNameController.clear();
    inputConditionValueController.clear();
  }

  void closeView(BuildContext context) {
    FocusScope.of(context).unfocus();
    if(kIsWeb) {
      _clearAll();
      _accountDashBoardController.rulesFilterCreatorIsActive.toggle();
    } else {
      popBack();
    }
  }
}