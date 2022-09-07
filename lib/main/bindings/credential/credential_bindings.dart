import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';

class CredentialBindings extends Bindings {

  @override
  void dependencies() {
    bindingsRepositoryImpl();
    bindingsRepository();
    bindingsInteractor();
  }

  void bindingsInteractor() {
    Get.put(GetCredentialInteractor(Get.find<CredentialRepository>()));
    Get.put(DeleteCredentialInteractor(Get.find<CredentialRepository>()));
  }

  void bindingsRepository() {
    Get.put<CredentialRepository>(Get.find<CredentialRepositoryImpl>());
  }

  void bindingsRepositoryImpl() {
    Get.put(CredentialRepositoryImpl(
        Get.find<SharedPreferences>(),
        Get.find<AuthenticationInfoCacheManager>()));
  }
}