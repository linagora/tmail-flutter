import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';

class IdentitiesBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => IdentitiesController(
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<DeleteIdentityInteractor>(),
      Get.find<CreateNewIdentityInteractor>(),
      Get.find<EditIdentityInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => CreateNewIdentityInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => DeleteIdentityInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => EditIdentityInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}