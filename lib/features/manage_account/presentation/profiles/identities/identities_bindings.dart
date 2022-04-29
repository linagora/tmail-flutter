import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart' as jmap_http_client;
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';

class IdentitiesBindings extends BaseBindings {

  @override
  void dependencies() {
    Get.lazyPut(() => ManageAccountAPI(Get.find<jmap_http_client.HttpClient>()));
    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => IdentitiesController(Get.find<GetAllIdentitiesInteractor>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ManageAccountDataSource>(() => Get.find<ManageAccountDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ManageAccountDataSourceImpl(Get.find<ManageAccountAPI>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ManageAccountRepository>(() => Get.find<ManageAccountRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ManageAccountRepositoryImpl(Get.find<ManageAccountDataSource>()));
  }
}