import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class SessionBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SessionDataSourceImpl(Get.find<SessionAPI>()));
    Get.lazyPut<SessionDataSource>(() => Get.find<SessionDataSourceImpl>());
    Get.lazyPut(() => SessionRepositoryImpl(Get.find<SessionDataSource>()));
    Get.lazyPut<SessionRepository>(() => Get.find<SessionRepositoryImpl>());
    Get.lazyPut(() => GetSessionInteractor(Get.find<SessionRepository>()));
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut(() => DeleteCredentialInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => SessionController(Get.find<GetSessionInteractor>(), Get.find<DeleteCredentialInteractor>()));
  }
}