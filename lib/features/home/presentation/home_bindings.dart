import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource_impl/cleanup_datasource_impl.dart';
import 'package:tmail_ui_user/features/cleanup/data/repository/cleanup_repository_impl.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => HomeController(
        Get.find<GetCredentialInteractor>(),
        Get.find<DynamicUrlInterceptors>(),
        Get.find<AuthorizationInterceptors>(),
        Get.find<CleanupEmailCacheInteractor>(),
        Get.find<EmailReceiveManager>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<CleanupDataSource>(() => Get.find<CleanupDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CleanupDataSourceImpl(
        Get.find<EmailCacheManager>(),
        Get.find<SharedPreferences>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => CleanupEmailCacheInteractor(Get.find<CleanupRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<CleanupRepository>(() => Get.find<CleanupRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => CleanupRepositoryImpl(Get.find<CleanupDataSource>()));
  }
}