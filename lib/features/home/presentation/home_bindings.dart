import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());

    Get.lazyPut(() => GetCredentialInteractor(Get.find<CredentialRepository>()));

    Get.lazyPut(() => HomeController(
      Get.find<GetCredentialInteractor>(),
      Get.find<DynamicUrlInterceptors>(),
      Get.find<AuthorizationInterceptors>()));
  }
}