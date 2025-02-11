import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/data/repository/identity_creator_repository_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/identity_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/identity_data_source_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/identity_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/transform_html_signature_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class IdentityInteractorsBindings extends InteractorsBindings {

  final String? composerId;

  IdentityInteractorsBindings({this.composerId});

  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<IdentityDataSource>(
      () => Get.find<IdentityDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<IdentityCreatorDataSource>(
      () => Get.find<LocalIdentityCreatorDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  void _bindingsUtils() {
    Get.lazyPut(() => IdentityUtils(), tag: composerId);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => IdentityDataSourceImpl(
      Get.find<HtmlTransform>(),
      Get.find<IdentityAPI>(),
      Get.find<RemoteExceptionThrower>()
    ), tag: composerId);
    Get.lazyPut(() => LocalIdentityCreatorDataSourceImpl(
      Get.find<CacheExceptionThrower>()
    ), tag: composerId);
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllIdentitiesInteractor(
      Get.find<IdentityRepository>(tag: composerId),
      Get.find<IdentityUtils>(tag: composerId)
    ), tag: composerId);
    Get.lazyPut(
      () => CreateNewIdentityInteractor(Get.find<IdentityRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => CreateNewDefaultIdentityInteractor(
      Get.find<IdentityRepository>(tag: composerId),
      Get.find<IdentityUtils>(tag: composerId)
    ), tag: composerId);
    Get.lazyPut(
      () => DeleteIdentityInteractor(Get.find<IdentityRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => EditIdentityInteractor(Get.find<IdentityRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => EditDefaultIdentityInteractor(
      Get.find<IdentityRepository>(tag: composerId),
      Get.find<IdentityUtils>(tag: composerId)
    ), tag: composerId);
    Get.lazyPut(
      () => TransformHtmlSignatureInteractor(Get.find<IdentityRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => SaveIdentityCacheOnWebInteractor(Get.find<IdentityCreatorRepository>(tag: composerId)),
      tag: composerId,
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<IdentityRepository>(
      () => Get.find<IdentityRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<IdentityCreatorRepository>(
      () => Get.find<IdentityCreatorRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => IdentityRepositoryImpl(Get.find<IdentityDataSource>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => IdentityCreatorRepositoryImpl(Get.find<IdentityCreatorDataSource>(tag: composerId)),
      tag: composerId,
    );
  }
}