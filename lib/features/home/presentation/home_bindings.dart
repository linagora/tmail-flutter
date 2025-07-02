import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/presentation/cleanup_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_auth_destination_url_interactor.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => HomeController(
      Get.find<CleanupEmailCacheInteractor>(),
      Get.find<EmailReceiveManager>(),
      Get.find<CleanupRecentLoginUrlCacheInteractor>(),
      Get.find<CleanupRecentLoginUsernameCacheInteractor>(),
      Get.find<CheckOIDCIsAvailableInteractor>(),
      Get.find<GetOIDCConfigurationInteractor>(),
      Get.find<AuthenticateOidcOnBrowserInteractor>(),
      Get.find<RemoveAuthDestinationUrlInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    CleanupBindings().dependencies();
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}