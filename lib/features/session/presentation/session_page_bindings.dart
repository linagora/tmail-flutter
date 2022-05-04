import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/presentation/session_controller.dart';

class SessionPageBindings extends BaseBindings {

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

  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}