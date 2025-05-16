import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension QuickCreateRuleFromCollapsedEmailSuccess on ThreadDetailController {
  void quickCreateRuleFromCollapsedEmailSuccess(
    CreateNewRuleFilterSuccess success,
  ) {
    if (success.newListRules.isEmpty ||
        currentContext == null ||
        currentOverlayContext == null) return;

    appToast.showToastSuccessMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).newFilterWasCreated,
    );
  }
}