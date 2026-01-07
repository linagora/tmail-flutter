import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_ai_scribe_config_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupCachedAiScribeExtension on MailboxDashBoardController {
  void loadAIScribeConfig() {
    getAIScribeConfigInteractor = getBinding<GetAIScribeConfigInteractor>();

    if (getAIScribeConfigInteractor != null) {
      consumeState(getAIScribeConfigInteractor!.execute());
    } else {
      handleLoadAIScribeConfigFailure();
    }
  }

  void handleLoadAIScribeConfigSuccess(AIScribeConfig aiScribeConfig) {
    cachedAIScribeConfig.value = aiScribeConfig;
  }

  void handleLoadAIScribeConfigFailure() {
    cachedAIScribeConfig.value = AIScribeConfig.initial();
  }
}
