import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

extension InitializeAppLanguage on MailboxDashBoardController {
  void initializeAppLanguage(GetServerSettingSuccess success) {
    LocalizationService.initializeAppLanguage(
      serverLanguage: success.settingOption.language,
      onServerLanguageApplied: (locale) {
        if (saveLanguageInteractor != null) {
          consumeState(saveLanguageInteractor!.execute(locale));
        }
      },
    );
  }
}