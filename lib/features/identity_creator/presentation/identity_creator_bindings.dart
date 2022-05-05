import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';

class IdentityCreatorBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => IdentityCreatorController(Get.find<VerifyNameInteractor>()));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => VerifyNameInteractor());
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}