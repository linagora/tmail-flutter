import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/bindings/setting_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/services/local_settings_service.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_bindings.dart';

class ManageAccountDashBoardBindings extends Bindings {

  @override
  void dependencies() {
    SettingInteractorBindings().dependencies();
    PaywallBindings().dependencies();
    // Ensure [LocalSettingsService] is available when the user navigates
    // directly to the settings route (e.g. web page reload), bypassing
    // [MailboxDashBoardBindings] which also registers it during a normal session.
    if (!Get.isRegistered<LocalSettingsService>()) {
      Get.put(LocalSettingsService(Get.find<GetLocalSettingsInteractor>()));
    }
    Get.put(ManageAccountDashBoardController());
    SettingsBindings().dependencies();
    ManageAccountMenuBindings().dependencies();
    IdentityBindings().dependencies();
  }
}