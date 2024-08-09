import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource/public_asset_datasource.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource_impl/remote_public_asset_datasource_impl.dart';
import 'package:tmail_ui_user/features/public_asset/data/network/public_asset_api.dart';
import 'package:tmail_ui_user/features/public_asset/data/repository/public_asset_repository_impl.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/add_identity_to_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/clean_up_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/remove_identity_from_public_assets_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class CleanUpPublicAssetsInteractorBindings extends InteractorsBindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PublicAssetApi(Get.find<HttpClient>(), Get.find<Uuid>()));
    
    super.dependencies();
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<PublicAssetDatasource>(
      () => Get.find<RemotePublicAssetDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemotePublicAssetDatasourceImpl(
      Get.find<PublicAssetApi>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => CleanUpPublicAssetsInteractor(
      Get.find<RemoveIdentityFromPublicAssetsInteractor>(),
      Get.find<DeletePublicAssetsInteractor>(),
      Get.find<AddIdentityToPublicAssetsInteractor>(),
    ));
    Get.lazyPut(
      () => RemoveIdentityFromPublicAssetsInteractor(Get.find<PublicAssetRepository>()));
    Get.lazyPut(
      () => DeletePublicAssetsInteractor(Get.find<PublicAssetRepository>()));
    Get.lazyPut(
      () => AddIdentityToPublicAssetsInteractor(Get.find<PublicAssetRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<PublicAssetRepository>(
      () => Get.find<PublicAssetRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => PublicAssetRepositoryImpl(
      Get.find<PublicAssetDatasource>()));
  }

  void close() {
    Get.delete<CleanUpPublicAssetsInteractor>();
    Get.delete<RemoveIdentityFromPublicAssetsInteractor>();
    Get.delete<DeletePublicAssetsInteractor>();
    Get.delete<AddIdentityToPublicAssetsInteractor>();
    Get.delete<PublicAssetRepository>();
    Get.delete<PublicAssetRepositoryImpl>();
    Get.delete<PublicAssetDatasource>();
    Get.delete<RemotePublicAssetDatasourceImpl>();
    Get.delete<PublicAssetApi>();
  }
}