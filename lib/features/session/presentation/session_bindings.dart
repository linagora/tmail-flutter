import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/datasource_impl/session_datasource_impl.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/features/session/data/repository/session_repository_impl.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/presentation/session_controller.dart';

class SessionBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => SessionController(
        Get.find<GetSessionInteractor>(),
        Get.find<DeleteCredentialInteractor>(),
        Get.find<CachingManager>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<SessionDataSource>(() => Get.find<SessionDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => SessionDataSourceImpl(Get.find<SessionAPI>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetSessionInteractor(Get.find<SessionRepository>()));
    Get.lazyPut(() => DeleteCredentialInteractor(Get.find<CredentialRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<SessionRepository>(() => Get.find<SessionRepositoryImpl>());
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => SessionRepositoryImpl(Get.find<SessionDataSource>()));
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
  }
}