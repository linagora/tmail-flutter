import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_email_rule_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_email_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_email_rule_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/context_item_email_rule_type_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/email_rule_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailRulesController extends BaseController {

  GetAllRulesInteractor? _getAllRulesInteractor;
  DeleteEmailRuleInteractor? _deleteEmailRuleInteractor;
  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  EditEmailRuleFilterInteractor? _editEmailRuleFilterInteractor;

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final listEmailRule = <TMailRule>[].obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _getAllRulesInteractor = Get.find<GetAllRulesInteractor>();
      _deleteEmailRuleInteractor = Get.find<DeleteEmailRuleInteractor>();
      _createNewEmailRuleFilterInteractor = Get.find<CreateNewEmailRuleFilterInteractor>();
      _editEmailRuleFilterInteractor = Get.find<EditEmailRuleFilterInteractor>();
    } catch (e) {
      logError('EmailRulesController::onInit(): ${e.toString()}');
    }
  }

  @override
  void onReady() {
    _getAllRules();
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllRulesSuccess) {
      if (success.rules?.isNotEmpty == true) {
        listEmailRule.addAll(success.rules!);
      }
    } else if (success is DeleteEmailRuleSuccess) {
      _handleDeleteEmailRuleSuccess(success);
    } else if (success is CreateNewRuleFilterSuccess) {
      _createNewRuleFilterSuccess(success);
    } else if (success is EditEmailRuleFilterSuccess) {
      _editEmailRuleFilterSuccess(success);
    }
  }

  void goToCreateNewRule(BuildContext context) async {
    final accountId = _accountDashBoardController.accountId.value;
    final session = _accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = RulesFilterCreatorArguments(accountId, session);

      final newRuleFilterRequest = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.rulesFilterCreator, arguments: arguments)
        : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

      if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
        _createNewRuleFilterAction(accountId, newRuleFilterRequest);
      }
    }
  }

  void _createNewRuleFilterAction(
      AccountId accountId,
      CreateNewEmailRuleFilterRequest ruleFilterRequest
  ) async {
    if (_createNewEmailRuleFilterInteractor != null) {
      consumeState(_createNewEmailRuleFilterInteractor!.execute(accountId, ruleFilterRequest));
    }
  }

  void _createNewRuleFilterSuccess(CreateNewRuleFilterSuccess success) {
    if (success.newListRules.isNotEmpty == true) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).newFilterWasCreated);
      }
      listEmailRule.value = success.newListRules;
      listEmailRule.refresh();
    }
  }

  void editEmailRule(BuildContext context, TMailRule rule) async {
    final accountId = _accountDashBoardController.accountId.value;
    final session = _accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = RulesFilterCreatorArguments(
        accountId,
        session,
        actionType: CreatorActionType.edit,
        tMailRule: rule);

      final newRuleFilterRequest = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.rulesFilterCreator, arguments: arguments)
        : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

      if (newRuleFilterRequest is EditEmailRuleFilterRequest) {
        _editEmailRuleFilterAction(accountId, newRuleFilterRequest);
      }
    }
  }

  void _editEmailRuleFilterAction(
      AccountId accountId,
      EditEmailRuleFilterRequest ruleFilterRequest
  ) {
    if (_editEmailRuleFilterInteractor != null) {
      consumeState(_editEmailRuleFilterInteractor!.execute(accountId, ruleFilterRequest));
    }
  }

  void _editEmailRuleFilterSuccess(EditEmailRuleFilterSuccess success) {
    if (success.listRulesUpdated.isNotEmpty == true) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).yourFilterHasBeenUpdated);
      }
      listEmailRule.value = success.listRulesUpdated;
      listEmailRule.refresh();
    }
  }

  void deleteEmailRule(BuildContext context, TMailRule emailRule) {
    if (responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).messageConfirmationDialogDeleteEmailRule(emailRule.name))
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () {
          _handleDeleteEmailRuleAction(emailRule);
        }))
      .show();
    } else {
      Get.dialog(
        PointerInterceptor(
          child: ConfirmationDialogBuilder(
            imagePath: imagePaths,
            title: AppLocalizations.of(context).deleteEmailRule,
            textContent: AppLocalizations.of(context).messageConfirmationDialogDeleteEmailRule(emailRule.name),
            cancelText: AppLocalizations.of(context).delete,
            confirmText: AppLocalizations.of(context).cancel,
            onCancelButtonAction: () => _handleDeleteEmailRuleAction(emailRule),
            onConfirmButtonAction: popBack,
            onCloseButtonAction: popBack,
          ),
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _handleDeleteEmailRuleAction(TMailRule emailRule) {
    popBack();

    if (emailRule.conditionGroup != null) {
      emailRule = TMailRule(
        id: emailRule.id,
        name: emailRule.name,
        action: emailRule.action,
        conditionGroup: emailRule.conditionGroup,
      );
    }

    listEmailRule.value = listEmailRule.map((rule) {
      if (rule.conditionGroup != null) {
        return TMailRule(
          id: rule.id,
          name: rule.name,
          action: rule.action,
          conditionGroup: rule.conditionGroup,
        );
      } else {
        return rule;
      }
    }).toList();

    if (_deleteEmailRuleInteractor != null) {
      final deleteEmailRuleRequest = DeleteEmailRuleRequest(
        emailRuleDelete : emailRule,
        currentEmailRules: listEmailRule,
      );

      consumeState(_deleteEmailRuleInteractor!.execute(
        _accountDashBoardController.accountId.value!,
        deleteEmailRuleRequest));
    }
  }

  void _handleDeleteEmailRuleSuccess(DeleteEmailRuleSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageDeleteEmailRuleSuccessfully);
    }

    if (success.rules?.isNotEmpty == true) {
      listEmailRule.clear();
      listEmailRule.addAll(success.rules!);
    }
  }

  void _getAllRules() {
    if (_getAllRulesInteractor != null) {
      consumeState(_getAllRulesInteractor!.execute(_accountDashBoardController.accountId.value!));
    }
  }

  void openEditRuleMenuAction(BuildContext context, TMailRule rule) {
    final contextMenuActions = [
      EmailRuleActionType.edit,
      EmailRuleActionType.delete,
    ].map((filter) {
      return ContextItemEmailRuleTypeAction(
        filter,
        AppLocalizations.of(context),
        imagePaths,
      );
    }).toList();

    openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (action) {
        popBack();
        _handleRuleFilterActionType(context, rule, action.action);
      },
    );
  }

  void _handleRuleFilterActionType(
    BuildContext context,
    TMailRule rule,
    EmailRuleActionType actionType,
  ) {
    switch (actionType) {
      case EmailRuleActionType.edit:
        editEmailRule(context, rule);
        break;
      case EmailRuleActionType.delete:
        deleteEmailRule(context, rule);
        break;
      case EmailRuleActionType.add:
        break;
    }
  }
}