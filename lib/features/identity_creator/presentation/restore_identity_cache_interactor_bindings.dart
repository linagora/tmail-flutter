import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/data/repository/identity_creator_repository_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/remove_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class RestoreIdentityCacheInteractorBindings extends InteractorsBindings {
  static const _tag = BindingTag.restoreIdentityCacheInteractorBindingsTag;

  @override
  void bindingsDataSource() {
    Get.lazyPut<IdentityCreatorDataSource>(
      () => Get.find<LocalIdentityCreatorDataSourceImpl>(tag: _tag),
      tag: _tag);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => LocalIdentityCreatorDataSourceImpl(
        Get.find<CacheExceptionThrower>()),
      tag: _tag);
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => GetIdentityCacheOnWebInteractor(
        Get.find<IdentityCreatorRepository>(tag: _tag)),
      tag: _tag);
    Get.lazyPut(
      () => RemoveIdentityCacheOnWebInteractor(
        Get.find<IdentityCreatorRepository>(tag: _tag)),
      tag: _tag);
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<IdentityCreatorRepository>(
      () => Get.find<IdentityCreatorRepositoryImpl>(tag: _tag),
      tag: _tag);
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => IdentityCreatorRepositoryImpl(
        Get.find<IdentityCreatorDataSource>(tag: _tag)),
      tag: _tag);
  }

  void close() {
    Get.delete<GetIdentityCacheOnWebInteractor>(tag: _tag);
    Get.delete<RemoveIdentityCacheOnWebInteractor>(tag: _tag);
  }
}