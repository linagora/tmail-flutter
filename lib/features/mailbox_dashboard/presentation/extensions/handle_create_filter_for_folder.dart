
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/rule_filter_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleCreateFilterForFolder on MailboxDashBoardController {

  Future<void> openCreateEmailRuleView(
    PresentationMailbox presentationMailbox,
  ) async {
    final accountId = this.accountId.value;
    final session = sessionCurrent;

    if (accountId == null) {
      consumeState(Stream.value(
          Left(CreateNewRuleFilterFailure(NotFoundAccountIdException()))));
      return;
    }

    if (session == null) {
      consumeState(Stream.value(
          Left(CreateNewRuleFilterFailure(NotFoundSessionException()))));
      return;
    }

    final arguments = RulesFilterCreatorArguments(
      accountId,
      session,
      mailboxDestination: presentationMailbox,
    );

    final newRuleFilterRequest = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(
          routeName: AppRoutes.rulesFilterCreator,
          arguments: arguments,
        )
      : await push(
          AppRoutes.rulesFilterCreator,
          arguments: arguments,
        );

    if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
      _createNewRuleFilterAction(accountId, newRuleFilterRequest);
    }
  }

  void _createNewRuleFilterAction(
    AccountId accountId,
    CreateNewEmailRuleFilterRequest ruleFilterRequest,
  ) {
    createNewEmailRuleFilterInteractor =
        getBinding<CreateNewEmailRuleFilterInteractor>();

    if (createNewEmailRuleFilterInteractor == null) {
      consumeState(Stream.value(
          Left(CreateNewRuleFilterFailure(RuleFilterNotBindingException()))));
      return;
    }

    consumeState(createNewEmailRuleFilterInteractor!.execute(
      accountId,
      ruleFilterRequest,
    ));
  }

  void handleCreateNewRuleFilterSuccess(CreateNewRuleFilterSuccess success) {
    if (success.newListRules.isNotEmpty == true) {
      toastManager.showMessageSuccess(success);
    }
  }

  void handleCreateNewRuleFilterFailure(CreateNewRuleFilterFailure failure) {
    toastManager.showMessageFailure(failure);
  }
}