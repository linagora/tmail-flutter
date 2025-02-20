import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';

class PreferencesBindings extends Bindings {

  @override
  void dependencies() {
    PreferencesInteractorsBindings().dependencies();

    Get.lazyPut(() => PreferencesController(
      Get.find<GetServerSettingInteractor>(),
      Get.find<UpdateServerSettingInteractor>(),
    ));
  }
}