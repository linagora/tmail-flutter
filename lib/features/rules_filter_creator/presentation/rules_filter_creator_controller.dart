
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RulesFilterCreatorController extends BaseMailboxController {

  final _appToast = Get.find<AppToast>();

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  GetAllRulesInteractor? _getAllRulesInteractor;

  final errorRuleName = Rxn<String>();
  final errorRuleConditionValue = Rxn<String>();
  final errorRuleActionValue = Rxn<String>();
  final ruleConditionFieldSelected = Rxn<rule_condition.Field>();
  final ruleConditionComparatorSelected = Rxn<rule_condition.Comparator>();
  final emailRuleFilterActionSelected = Rxn<EmailRuleFilterAction>();
  final mailboxSelected = Rxn<PresentationMailbox>();
  final actionType = CreatorActionType.create.obs;

  final TextEditingController inputRuleNameController = TextEditingController();
  final TextEditingController inputConditionValueController = TextEditingController();
  final FocusNode inputRuleNameFocusNode = FocusNode();
  final FocusNode inputRuleConditionFocusNode = FocusNode();

  String? _newRuleName;
  String? _newRuleConditionValue;

  RulesFilterCreatorArguments? arguments;
  AccountId? _accountId;
  Session? _session;
  TMailRule? _currentTMailRule;
  EmailAddress? _emailAddress;
  List<TMailRule>? _listEmailRule;

  RulesFilterCreatorController(
    this._getAllMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
  ) : super(treeBuilder, verifyNameInteractor);

  @override
  void onInit() {
    super.onInit();
    log('RulesFilterCreatorController::onInit():arguments: ${Get.arguments}');
    arguments = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    log('RulesFilterCreatorController::onReady():');
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _session = arguments!.session;
      _currentTMailRule = arguments!.tMailRule;
      _emailAddress = arguments!.emailAddress;
      actionType.value = arguments!.actionType;
      injectRuleFilterBindings(_session, _accountId);
      try {
        _getAllRulesInteractor = Get.find<GetAllRulesInteractor>();
      } catch (e) {
        logError('RulesFilterCreatorController::onInit(): ${e.toString()}');
      }
      _setUpDefaultValueRuleFilter();
      _getAllRules();
    }
  }

  @override
  void onClose() {
    log('RulesFilterCreatorController::onClose():');
    inputRuleNameFocusNode.dispose();
    inputRuleConditionFocusNode.dispose();
    inputRuleNameController.dispose();
    inputConditionValueController.dispose();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess) {
      await buildTree(success.mailboxList);
      _setUpMailboxSelected();
      if (currentContext != null) {
        await syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is GetAllRulesSuccess) {
      log('RulesFilterCreatorController::handleSuccessViewState():GetAllRulesSuccess: ${success.rules}');
      if (success.rules?.isNotEmpty == true) {
        _listEmailRule = success.rules!;
      }
    }
  }

  void _getAllRules() {
    if (_accountId != null && _getAllRulesInteractor != null) {
      consumeState(_getAllRulesInteractor!.execute(_accountId!));
    }
  }

  void _setUpDefaultValueRuleFilter() {
    switch(actionType.value) {
      case CreatorActionType.create:
        ruleConditionFieldSelected.value = rule_condition.Field.from;
        ruleConditionComparatorSelected.value = rule_condition.Comparator.contains;
        emailRuleFilterActionSelected.value = EmailRuleFilterAction.moveMessage;
        if (_emailAddress != null) {
          _newRuleConditionValue = _emailAddress?.email;
          _setValueInputField(inputConditionValueController, _newRuleConditionValue ?? '');
        }
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
      consumeState(_getAllMailboxInteractor.execute(_session!, _accountId!));
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
    return verifyNameInteractor.execute(inputValue, [EmptyNameValidator()]).fold(
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
        MailboxActions.selectForRuleAction,
        _session);

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox is PresentationMailbox && context.mounted) {
        mailboxSelected.value = destinationMailbox;
        errorRuleActionValue.value = _getErrorStringByInputValue(
          context,
          mailboxSelected.value?.getDisplayName(context));
      }
    }
  }

  void createNewRuleFilter(BuildContext context) async {
    KeyboardUtils.hideKeyboard(context);

    final errorName = _getErrorStringByInputValue(context, _newRuleName);
    if (errorName?.isNotEmpty == true) {
      errorRuleName.value = errorName;
      inputRuleNameFocusNode.requestFocus();
      return;
    }

    final errorCondition = _getErrorStringByInputValue(context, _newRuleConditionValue);
    if (errorCondition?.isNotEmpty == true) {
      errorRuleConditionValue.value = errorCondition;
      inputRuleConditionFocusNode.requestFocus();
      return;
    }

    final errorAction = _getErrorStringByInputValue(context, mailboxSelected.value?.getDisplayName(context));
    if (errorAction?.isNotEmpty == true) {
      errorRuleActionValue.value = errorAction;
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).this_field_cannot_be_blank);
      }
      return;
    }

    if (ruleConditionFieldSelected.value == null ||
        ruleConditionComparatorSelected.value == null ||
        emailRuleFilterActionSelected.value == null) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastErrorMessageWhenCreateNewRule);
      }
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

    final ruleFilterRequest =
    actionType.value == CreatorActionType.create
      ? CreateNewEmailRuleFilterRequest(_listEmailRule ?? [], newTMailRule)
      : EditEmailRuleFilterRequest(_listEmailRule?.withIds ?? [], newTMailRule);
    popBack(result: ruleFilterRequest);
  }

  void closeView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }
}