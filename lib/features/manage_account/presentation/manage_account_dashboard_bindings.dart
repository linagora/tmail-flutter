import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';

class ManageAccountDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    ManageAccountMenuBindings().dependencies();
    ProfileBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => ManageAccountDashBoardController(
      Get.find<GetUserProfileInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}