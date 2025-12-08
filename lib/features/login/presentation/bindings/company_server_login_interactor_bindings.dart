import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/company_server_login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/company_server_login_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/company_server_login_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/repository/company_server_login_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/company_server_login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class CompanyServerLoginInteractorBindings extends InteractorsBindings {
  @override
  void dependencies() {
    Get.put(CompanyServerLoginCacheManager(Get.find<SharedPreferences>()));
    super.dependencies();
  }

  @override
  void bindingsDataSource() {
    Get.put<CompanyServerLoginDataSource>(
      Get.find<CompanyServerLoginDatasourceImpl>(),
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(
      CompanyServerLoginDatasourceImpl(
        Get.find<CompanyServerLoginCacheManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.put(
      SaveCompanyServerLoginInfoInteractor(
        Get.find<CompanyServerLoginRepository>(),
      ),
    );
    Get.put(
      GetCompanyServerLoginInfoInteractor(
        Get.find<CompanyServerLoginRepository>(),
      ),
    );
    Get.put(
      RemoveCompanyServerLoginInfoInteractor(
        Get.find<CompanyServerLoginRepository>(),
      ),
    );
  }

  @override
  void bindingsRepository() {
    Get.put<CompanyServerLoginRepository>(
      Get.find<CompanyServerLoginRepositoryImpl>(),
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(
      CompanyServerLoginRepositoryImpl(
        Get.find<CompanyServerLoginDataSource>(),
      ),
    );
  }
}
