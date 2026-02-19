import 'package:core/utils/app_logger.dart';
import 'package:scribe/scribe/ai/domain/service/prompt_service.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_scribe_prompt_url_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_scribe_prompt_url_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupScribePromptUrlExtension on MailboxDashBoardController {
  void loadScribePromptUrl() {
    final interactor = getBinding<GetScribePromptUrlInteractor>();
    
    if (interactor != null) {
      final baseUrl = dynamicUrlInterceptors.jmapUrl;
      if (baseUrl != null && baseUrl.isNotEmpty) {
        consumeState(interactor.execute(baseUrl));
      } else {
        logError('SetupScribePromptUrlExtension::loadScribePromptUrl: jmapUrl is null or empty');
      }
    } else {
      logError('SetupScribePromptUrlExtension::loadScribePromptUrl: GetScribePromptUrlInteractor not found');
    }
  }

  void handleGetScribePromptUrlSuccess(GetScribePromptUrlSuccess success) {
    PromptService().setPromptUrl(success.promptUrl);
  }

  void handleGetScribePromptUrlFailure(GetScribePromptUrlFailure failure) {
    logError('SetupScribePromptUrlExtension::handleGetScribePromptUrlFailure: GetScribePromptUrl failed - ${failure.exception}');
    PromptService().setPromptUrl(null);
  }
}
