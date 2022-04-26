import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_controller.dart';

class ProfileBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    IdentitiesBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => ProfilesController());
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