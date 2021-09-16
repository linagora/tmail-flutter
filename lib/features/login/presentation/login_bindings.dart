import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthenticationDataSourceImpl());
    Get.lazyPut<AuthenticationDataSource>(() => Get.find<AuthenticationDataSourceImpl>());

    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());

    Get.lazyPut(() => AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
    Get.lazyPut<AuthenticationRepository>(() => Get.find<AuthenticationRepositoryImpl>());

    Get.lazyPut(() => AuthenticationInteractor(Get.find<AuthenticationRepository>(), Get.find<CredentialRepository>()));

    Get.lazyPut(() => LoginController(
      Get.find<AuthenticationInteractor>(),
      Get.find<DynamicUrlInterceptors>(),
      Get.find<AuthorizationInterceptors>())
    );
  }
}