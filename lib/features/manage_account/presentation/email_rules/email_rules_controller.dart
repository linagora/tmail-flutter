import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';
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

  final listEmailRule = <TMailRule>[].obs;

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
        if (success.rules?.isNotEmpty == true) {
          listEmailRule.clear();
          listEmailRule.addAll(success.rules!);
        }
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
      final newEmailRuleFilter = await push(
          AppRoutes.RULES_FILTER_CREATOR,
          arguments: RulesFilterCreatorArguments(accountId));

      if (newEmailRuleFilter is TMailRule) {
        _createNewRuleFilterAction(
          accountId,
          CreateNewEmailRuleFilterRequest(
              listEmailRule,
              newEmailRuleFilter)
        );
      }
    }
  }

  void _createNewRuleFilterAction(
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
      final emailRuleFilterChanged = await push(
          AppRoutes.RULES_FILTER_CREATOR,
          arguments: RulesFilterCreatorArguments(
              accountId,
              actionType: CreatorActionType.edit,
              tMailRule: rule));

      if (emailRuleFilterChanged is TMailRule) {
        final newListRuleWithIds = listEmailRule.withIds;
        _editEmailRuleFilterAction(
            accountId,
            EditEmailRuleFilterRequest(newListRuleWithIds, emailRuleFilterChanged)
        );
      }
    }
  }

  void _editEmailRuleFilterAction(
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

  void deleteEmailRule(TMailRule emailRule) {
    final deleteEmailRuleRequest = DeleteEmailRuleRequest(
      emailRuleDelete : emailRule,
      currentEmailRules: listEmailRule,
    );
    consumeState(_deleteEmailRuleInteractor.execute(_accountDashBoardController.accountId.value!, deleteEmailRuleRequest));
  }

  void _getAllRules() {
    consumeState(_getAllRulesInteractor.execute(_accountDashBoardController.accountId.value!));
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
      deleteEmailRule(rule);
      popBack();
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