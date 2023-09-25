import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_stored_session_interactor.dart';
import 'package:tmail_ui_user/features/session/presentation/session_controller.dart';

class SessionPageBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => SessionController(
      Get.find<GetAuthenticatedAccountInteractor>(),
      Get.find<UpdateAuthenticationAccountInteractor>(),
      Get.find<GetSessionInteractor>(),
      Get.find<AppToast>(),
      Get.find<DynamicUrlInterceptors>(),
      Get.find<GetStoredSessionInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => UpdateAuthenticationAccountInteractor(Get.find<AccountRepository>()));
    Get.lazyPut(() => GetStoredSessionInteractor(Get.find<SessionRepository>()));
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}