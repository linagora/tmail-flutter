
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
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
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnCreatedRuleFilterCallback = Function(dynamic arguments);

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
  final actionType = CreatorActionType.create.obs;

  TextEditingController? inputRuleNameController;
  TextEditingController? inputConditionValueController;
  FocusNode? inputRuleNameFocusNode;
  FocusNode? inputRuleConditionFocusNode;

  String? _newRuleName;
  String? _newRuleConditionValue;

  RulesFilterCreatorArguments? arguments;
  OnCreatedRuleFilterCallback? onCreatedRuleFilterCallback;
  VoidCallback? onDismissRuleFilterCreator;
  AccountId? _accountId;
  TMailRule? _currentTMailRule;
  List<TMailRule>? _listEmailRule;

  RulesFilterCreatorController(
    this._verifyNameInteractor,
    this._getAllMailboxInteractor,
    treeBuilder
  ) : super(treeBuilder);

  @override
  void onInit() {
    super.onInit();
    inputRuleNameController = TextEditingController();
    inputConditionValueController = TextEditingController();
    inputRuleNameFocusNode = FocusNode();
    inputRuleConditionFocusNode = FocusNode();
  }

  @override
  void onReady() {
    super.onReady();
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _currentTMailRule = arguments!.tMailRule;
      _listEmailRule = arguments!.listEmailRule;
      actionType.value = arguments!.actionType;
      _setUpDefaultValueRuleFilter();
    }
  }

  @override
  void onClose() {
    _disposeWidget();
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
    switch(actionType.value) {
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
    inputRuleNameFocusNode?.requestFocus();
  }

  void _setValueInputField(TextEditingController? controller, String value) {
    controller?.value = controller.value.copyWith(
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
    if (_accountId != null) {
      final arguments = DestinationPickerArguments(
          _accountId!,
          MailboxActions.selectForRuleAction);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              mailboxSelected.value = destinationMailbox;
              errorRuleActionValue.value = _getErrorStringByInputValue(
                  context,
                  mailboxSelected.value?.name?.name);
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox is PresentationMailbox) {
          mailboxSelected.value = destinationMailbox;
          errorRuleActionValue.value = _getErrorStringByInputValue(
              context,
              mailboxSelected.value?.name?.name);
        }
      }
    }
  }

  void createNewRuleFilter(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final errorName = _getErrorStringByInputValue(context, _newRuleName);
    if (errorName?.isNotEmpty == true) {
      errorRuleName.value = errorName;
      inputRuleNameFocusNode?.requestFocus();
      return;
    }

    final errorCondition = _getErrorStringByInputValue(context, _newRuleConditionValue);
    if (errorCondition?.isNotEmpty == true) {
      errorRuleConditionValue.value = errorCondition;
      inputRuleConditionFocusNode?.requestFocus();
      return;
    }

    final errorAction = _getErrorStringByInputValue(context, mailboxSelected.value?.name?.name);
    if (errorAction?.isNotEmpty == true) {
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

    if (actionType.value == CreatorActionType.create) {
      final ruleFilterRequest = CreateNewEmailRuleFilterRequest(
        _listEmailRule ?? [],
        newTMailRule);

      if (BuildUtils.isWeb) {
        _disposeWidget();
        onCreatedRuleFilterCallback?.call(ruleFilterRequest);
      } else {
        popBack(result: ruleFilterRequest);
      }
    } else {
      final ruleFilterRequest = EditEmailRuleFilterRequest(
        _listEmailRule?.withIds ?? [],
        newTMailRule);

      if (BuildUtils.isWeb) {
        _disposeWidget();
        onCreatedRuleFilterCallback?.call(ruleFilterRequest);
      } else {
        popBack(result: ruleFilterRequest);
      }
    }
  }

  void _clearAll() {
    inputRuleNameController?.clear();
    inputConditionValueController?.clear();
  }

  void _disposeWidget() {
    inputRuleNameFocusNode?.dispose();
    inputRuleNameFocusNode = null;
    inputRuleConditionFocusNode?.dispose();
    inputRuleConditionFocusNode = null;
    inputRuleNameController?.dispose();
    inputRuleNameController = null;
    inputConditionValueController?.dispose();
    inputConditionValueController = null;
  }

  void closeView(BuildContext context) {
    _clearAll();
    FocusScope.of(context).unfocus();

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onDismissRuleFilterCreator?.call();
    } else {
      popBack();
    }
  }
}