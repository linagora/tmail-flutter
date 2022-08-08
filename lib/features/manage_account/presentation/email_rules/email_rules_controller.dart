import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rule_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailRulesController extends BaseController {
  final listEmailRule = <TMailRule>[].obs;
  final _accountDashBoardController =
      Get.find<ManageAccountDashBoardController>();
  final GetAllRulesInteractor _getAllRulesInteractor;
  final _imagePaths = Get.find<ImagePaths>();
  late Worker accountIdWorker;

  EmailRulesController(this._getAllRulesInteractor);

  void _clearWorker() {
    accountIdWorker.call();
  }

  @override
  void onDone() {
    viewState.value.fold((failure) {}, (success) {
      if (success is GetAllRulesSuccess) {
        if (success.rules?.isNotEmpty == true) {
          listEmailRule.addAll(success.rules!);
        }
      }
    });
  }

  @override
  void onError(error) {}

  @override
  void onInit() {
    _getAllRules(_accountDashBoardController.accountId.value!);
    super.onInit();
  }

  @override
  void onClose() {
    _clearWorker();
    super.onClose();
  }

  void goToCreateNewRule() {
    //TODO: goToCreateNewRule
  }

  void editEmailRule(TMailRule rule) {
    //TODO: editEmailRule
  }

  void deleteEmailRule(TMailRule rule) {
    //TODO: deleteEmailRule
  }

  void _getAllRules(AccountId accountId) {
    consumeState(_getAllRulesInteractor.execute(accountId));
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
    )..onActionClick((rule) => deleteEmailRule(rule)))
        .build();
  }

  Widget _editEmailRuleActionTile(BuildContext context, TMailRule rule) {
    return (EmailRuleBottomSheetActionTileBuilder(
      const Key('edit_emailRule_action'),
      SvgPicture.asset(_imagePaths.icEdit),
      AppLocalizations.of(context).editRule,
      rule,
      iconLeftPadding: const EdgeInsets.only(left: 12, right: 16),
      iconRightPadding: const EdgeInsets.only(right: 12),
    )..onActionClick((rule) => editEmailRule(rule)))
        .build();
  }
}
