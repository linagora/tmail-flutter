import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class ManageAccountDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    SettingsBindings().dependencies();
    ManageAccountMenuBindings().dependencies();
    ProfileBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.put(ManageAccountDashBoardController(
      Get.find<GetAuthenticatedAccountInteractor>(),
      Get.find<UpdateAuthenticationAccountInteractor>()
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ManageAccountDataSource>(() => Get.find<ManageAccountDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ManageAccountDataSourceImpl(
      Get.find<LanguageCacheManager>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => UpdateAuthenticationAccountInteractor(Get.find<AccountRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ManageAccountRepository>(() => Get.find<ManageAccountRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ManageAccountRepositoryImpl(Get.find<ManageAccountDataSource>()));
  }
}