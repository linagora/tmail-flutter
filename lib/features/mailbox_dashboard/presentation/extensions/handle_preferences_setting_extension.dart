
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_interactors_bindings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandlePreferencesSettingExtension on MailboxDashBoardController {

  bool get isServerSettingsCapabilitySupported {
    if (accountId.value == null || sessionCurrent == null) return false;

    return capabilityServerSettings.isSupported(
      sessionCurrent!,
      accountId.value!,
    );
  }

  void injectPreferencesBindings() {
    if (isServerSettingsCapabilitySupported) {
      PreferencesInteractorsBindings().dependencies();
      getServerSettingInteractor = getBinding<GetServerSettingInteractor>();
    }
  }

  void getServerSetting() {
    if (accountId.value == null || getServerSettingInteractor == null) return;

    consumeState(getServerSettingInteractor!.execute(accountId.value!));
  }
}