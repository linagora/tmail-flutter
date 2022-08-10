
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RulesFilterCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  final actionType = CreatorActionType.create.obs;
  final errorRuleName = Rxn<String>();
  final errorConditionValue = Rxn<String>();
  final ruleConditionFieldSelected = Rxn<rule_condition.Field>();
  final ruleConditionComparatorSelected = Rxn<rule_condition.Comparator>();
  final emailRuleFilterActionSelected = Rxn<EmailRuleFilterAction>();
  final mailboxSelected = Rxn<PresentationMailbox>();
  final isCreateRuleFilterValid = RxBool(false);

  final inputRuleNameController = TextEditingController();
  final inputConditionValueController = TextEditingController();

  AccountId? _accountId;
  String? _newRuleName;
  String? _newConditionValue;

  RulesFilterCreatorController(this._verifyNameInteractor);

  @override
  void onReady() {
    _getArguments();
    _setUpDefaultValueRuleFilter();
    super.onReady();
  }

  @override
  void onClose() {
    inputRuleNameController.dispose();
    inputConditionValueController.dispose();
    super.onClose();
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is RulesFilterCreatorArguments) {
      _accountId = arguments.accountId;
      actionType.value = arguments.actionType;
    }
  }

  void _setUpDefaultValueRuleFilter() {
    if (actionType.value == CreatorActionType.create) {
      ruleConditionFieldSelected.value = rule_condition.Field.from;
      ruleConditionComparatorSelected.value = rule_condition.Comparator.exactlyEquals;
      emailRuleFilterActionSelected.value = EmailRuleFilterAction.moveMessage;
    }

    _updateStateCreatorButton();
  }

  void updateRuleName(BuildContext context, String? value) {
    _newRuleName = value;
    errorRuleName.value = _getErrorStringByInputValue(context, _newRuleName);
    _updateStateCreatorButton();
  }

  void updateConditionValue(BuildContext context, String? value) {
    _newConditionValue = value;
    errorConditionValue.value = _getErrorStringByInputValue(context, _newConditionValue);
    _updateStateCreatorButton();
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
    _updateStateCreatorButton();
  }

  void selectRuleConditionComparator(rule_condition.Comparator? newComparator) {
    ruleConditionComparatorSelected.value = newComparator;
    _updateStateCreatorButton();
  }

  void selectEmailRuleFilterAction(EmailRuleFilterAction? newAction) {
    emailRuleFilterActionSelected.value = newAction;
    _updateStateCreatorButton();
  }

  void selectMailbox() async {
    final destinationMailbox = await push(
        AppRoutes.DESTINATION_PICKER,
        arguments: DestinationPickerArguments(
            _accountId!,
            MailboxActions.selectForRuleAction));

    if (destinationMailbox is PresentationMailbox) {
      mailboxSelected.value = destinationMailbox;
      _updateStateCreatorButton();
    }
  }

  void _updateStateCreatorButton() {
    isCreateRuleFilterValid.value = _newRuleName?.trim().isNotEmpty == true &&
      _newConditionValue?.trim().isNotEmpty == true &&
      mailboxSelected.value != null &&
      ruleConditionFieldSelected.value != null &&
      emailRuleFilterActionSelected.value != null &&
      ruleConditionComparatorSelected.value != null;
  }

  void createNewRuleFilter(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final errorName = _getErrorStringByInputValue(context, _newRuleName);
    if (errorName?.isNotEmpty == true) {
      log('RulesFilterCreatorController::createNewRuleFilter(): errorName: $errorName');
      errorRuleName.value = errorName;
      return;
    }

    final errorCondition = _getErrorStringByInputValue(context, _newConditionValue);
    if (errorCondition?.isNotEmpty == true) {
      log('RulesFilterCreatorController::createNewRuleFilter(): errorCondition: $errorCondition');
      errorConditionValue.value = errorName;
      return;
    }

    final newTMailRule = TMailRule(
        name: _newRuleName!,
        action: RuleAction(
          appendIn: RuleAppendIn(
            mailboxIds: [mailboxSelected.value!.id]
          )
        ),
        condition: rule_condition.RuleCondition(
          field: ruleConditionFieldSelected.value!,
          comparator: ruleConditionComparatorSelected.value!,
          value: _newConditionValue!
        ));

    log('RulesFilterCreatorController::newTMailRule(): $newTMailRule');

    _clearAll();
    popBack(result: newTMailRule);
  }

  void _clearAll() {
    inputRuleNameController.clear();
    inputConditionValueController.clear();
  }

  void closeView(BuildContext context) {
    FocusScope.of(context).unfocus();
    popBack();
  }
}