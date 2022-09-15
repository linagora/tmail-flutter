import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_email_rule_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_email_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_email_rule_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rule_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class EmailRulesController extends BaseController {

  final GetAllRulesInteractor _getAllRulesInteractor;
  final DeleteEmailRuleInteractor _deleteEmailRuleInteractor;
  final CreateNewEmailRuleFilterInteractor _createNewEmailRuleFilterInteractor;
  final EditEmailRuleFilterInteractor _editEmailRuleFilterInteractor;

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final listEmailRule = <TMailRule>[].obs;

  final rulesFilterCreatorArguments = Rxn<RulesFilterCreatorArguments>();

  EmailRulesController(
    this._getAllRulesInteractor,
    this._deleteEmailRuleInteractor,
    this._createNewEmailRuleFilterInteractor,
    this._editEmailRuleFilterInteractor,
  );

  @override
  void onDone() {
    viewState.value.fold((failure) {}, (success) {
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
    });
  }

  @override
  void onError(error) {}

  @override
  void onInit() {
    _getAllRules();
    super.onInit();
  }

  void goToCreateNewRule() async {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      rulesFilterCreatorArguments.value = RulesFilterCreatorArguments(accountId);
      if(kIsWeb) {
        _openRulesFilterCreatorOverlay();
      } else {
        push(
          AppRoutes.RULES_FILTER_CREATOR,
        );
      }
    }
  }

  void createNewRuleFilterAction(
      AccountId accountId,
      CreateNewEmailRuleFilterRequest ruleFilterRequest
  ) async {
    consumeState(_createNewEmailRuleFilterInteractor.execute(
        accountId,
        ruleFilterRequest));
  }

  void _createNewRuleFilterSuccess(CreateNewRuleFilterSuccess success) {
    if (success.newListRules.isNotEmpty == true) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).newFilterWasCreated,
            icon: _imagePaths.icSelected);
      }
      log('EmailRulesController::_createNewRuleFilterSuccess(): ${success.newListRules}');
      listEmailRule.value = success.newListRules;
      listEmailRule.refresh();
    }
  }

  void editEmailRule(TMailRule rule) async {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      rulesFilterCreatorArguments.value = RulesFilterCreatorArguments(
        accountId,
        actionType: CreatorActionType.edit,
        tMailRule: rule,
      );
      if(kIsWeb) {
        _openRulesFilterCreatorOverlay();
      } else {
        push(
          AppRoutes.RULES_FILTER_CREATOR,
        );
      }
    }
  }

  void editEmailRuleFilterAction(
      AccountId accountId,
      EditEmailRuleFilterRequest ruleFilterRequest
  ) {
    consumeState(_editEmailRuleFilterInteractor.execute(accountId, ruleFilterRequest));
  }

  void _editEmailRuleFilterSuccess(EditEmailRuleFilterSuccess success) {
    if (success.listRulesUpdated.isNotEmpty == true) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).yourFilterHasBeenUpdated,
            icon: _imagePaths.icSelected);
      }
      log('EmailRulesController::_editEmailRuleFilterSuccess(): ${success.listRulesUpdated}');
      listEmailRule.value = success.listRulesUpdated;
      listEmailRule.refresh();
    }
  }

  void deleteEmailRule(BuildContext context, TMailRule emailRule) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).messageConfirmationDialogDeleteEmailRule(emailRule.name))
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () {
          _handleDeleteEmailRuleAction(emailRule);
        }))
      .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) =>
              PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
                ..title(AppLocalizations.of(context).deleteEmailRule)
                ..content(AppLocalizations.of(context).messageConfirmationDialogDeleteEmailRule(emailRule.name))
                ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog,
                    fit: BoxFit.fill))
                ..marginIcon(EdgeInsets.zero)
                ..colorConfirmButton(AppColor.colorConfirmActionDialog)
                ..styleTextConfirmButton(const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColor.colorActionDeleteConfirmDialog))
                ..onCloseButtonAction(() => popBack())
                ..onConfirmButtonAction(AppLocalizations.of(context).delete, () {
                  _handleDeleteEmailRuleAction(emailRule);
                })
                ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                    popBack()))
              .build()));
    }
  }

  void _handleDeleteEmailRuleAction(TMailRule emailRule) {
    popBack();

    final deleteEmailRuleRequest = DeleteEmailRuleRequest(
      emailRuleDelete : emailRule,
      currentEmailRules: listEmailRule,
    );
    consumeState(_deleteEmailRuleInteractor.execute(
        _accountDashBoardController.accountId.value!,
        deleteEmailRuleRequest));
  }

  void _handleDeleteEmailRuleSuccess(DeleteEmailRuleSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).toastMessageDeleteEmailRuleSuccessfully,
        icon: _imagePaths.icSelected,
      );
    }

    if (success.rules?.isNotEmpty == true) {
      listEmailRule.clear();
      listEmailRule.addAll(success.rules!);
    }
  }

  void _getAllRules() {
    consumeState(_getAllRulesInteractor.execute(_accountDashBoardController.accountId.value!));
  }

  void _openRulesFilterCreatorOverlay() {
    RulesFilterCreatorBindings().dependencies();
    _accountDashBoardController.rulesFilterCreatorIsActive.toggle();
  }

  void openEditRuleMenuAction(BuildContext context, TMailRule rule) {
    openContextMenuAction(
      context,
      [
        _editEmailRuleActionTile(context, rule),
        _deleteEmailRuleActionTile(context, rule),
      ],
    );
  }

  Widget _deleteEmailRuleActionTile(BuildContext context, TMailRule rule) {
    return (EmailRuleBottomSheetActionTileBuilder(
      const Key('delete_emailRule_action'),
      SvgPicture.asset(_imagePaths.icDeleteComposer,
          color: AppColor.colorActionDeleteConfirmDialog),
      AppLocalizations.of(context).deleteRule,
      rule,
      iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
      iconRightPadding: const EdgeInsets.only(right: 12),
      textStyleAction: const TextStyle(
          fontSize: 17, color: AppColor.colorActionDeleteConfirmDialog),
    )..onActionClick((rule) {
      popBack();
      deleteEmailRule(context, rule);
    })).build();
  }

  Widget _editEmailRuleActionTile(BuildContext context, TMailRule rule) {
    return (EmailRuleBottomSheetActionTileBuilder(
          const Key('edit_emailRule_action'),
          SvgPicture.asset(_imagePaths.icEdit),
          AppLocalizations.of(context).editRule,
          rule,
          iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
          iconRightPadding: const EdgeInsets.only(right: 12))
      ..onActionClick((rule) {
        popBack();
        editEmailRule(rule);
      }))
    .build();
  }
}