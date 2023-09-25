import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_controller.dart';

class MailtoUrlBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => MailtoUrlController(
      Get.find<GetAuthenticatedAccountInteractor>(),
      Get.find<UpdateAuthenticationAccountInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => UpdateAuthenticationAccountInteractor(Get.find<AccountRepository>()));
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}