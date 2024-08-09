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
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class CleanUpPublicAssetsInteractorBindings extends InteractorsBindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PublicAssetApi(Get.find<HttpClient>(), Get.find<Uuid>()),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    
    super.dependencies();
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<PublicAssetDatasource>(
      () => Get.find<RemotePublicAssetDatasourceImpl>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => RemotePublicAssetDatasourceImpl(
        Get.find<PublicAssetApi>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        Get.find<RemoteExceptionThrower>()),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => CleanUpPublicAssetsInteractor(
        Get.find<RemoveIdentityFromPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        Get.find<DeletePublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        Get.find<AddIdentityToPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag)),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.lazyPut(
      () => RemoveIdentityFromPublicAssetsInteractor(Get.find<PublicAssetRepository>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag)),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.lazyPut(
      () => DeletePublicAssetsInteractor(Get.find<PublicAssetRepository>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag)),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.lazyPut(
      () => AddIdentityToPublicAssetsInteractor(Get.find<PublicAssetRepository>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag)),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<PublicAssetRepository>(
      () => Get.find<PublicAssetRepositoryImpl>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => PublicAssetRepositoryImpl(Get.find<PublicAssetDatasource>(
        tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag)),
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }

  void close() {
    Get.delete<CleanUpPublicAssetsInteractor>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<RemoveIdentityFromPublicAssetsInteractor>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<DeletePublicAssetsInteractor>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<AddIdentityToPublicAssetsInteractor>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<PublicAssetRepository>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<PublicAssetRepositoryImpl>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<PublicAssetDatasource>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<RemotePublicAssetDatasourceImpl>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    Get.delete<PublicAssetApi>(tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
  }
}