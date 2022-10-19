import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/identity_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/identity_data_source_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/identity_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';

class IdentityInteractorsBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<IdentityDataSource>(() => Get.find<IdentityDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => IdentityDataSourceImpl(Get.find<IdentityAPI>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<IdentityRepository>()));
    Get.lazyPut(() => CreateNewIdentityInteractor(Get.find<IdentityRepository>()));
    Get.lazyPut(() => DeleteIdentityInteractor(Get.find<IdentityRepository>()));
    Get.lazyPut(() => EditIdentityInteractor(Get.find<IdentityRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<IdentityRepository>(() => Get.find<IdentityRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => IdentityRepositoryImpl(Get.find<IdentityDataSource>()));
  }
}