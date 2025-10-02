import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/bindings/setting_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_bindings.dart';

class ManageAccountDashBoardBindings extends Bindings {

  @override
  void dependencies() {
    SettingInteractorBindings().dependencies();
    Get.put(ManageAccountDashBoardController());
    SettingsBindings().dependencies();
    ManageAccountMenuBindings().dependencies();
    IdentityBindings().dependencies();
  }
}