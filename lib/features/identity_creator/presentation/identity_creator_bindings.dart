import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/data/repository/identity_creator_repository_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class IdentityCreatorBindings extends BaseBindings {
  @override
  void bindingsController() {
    Get.lazyPut(() => IdentityCreatorController(
      Get.find<VerifyNameInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<SaveIdentityCacheOnWebInteractor>(),
      Get.find<IdentityUtils>()
    ));
  }
  
  @override
  void bindingsDataSource() {
    Get.lazyPut<IdentityCreatorDataSource>(() => Get.find<LocalIdentityCreatorDataSourceImpl>());
  }
  
  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => LocalIdentityCreatorDataSourceImpl(
      Get.find<CacheExceptionThrower>()
    ));
  }
  
  @override
  void bindingsInteractor() {
    IdentityInteractorsBindings().dependencies();
    Get.lazyPut(() => VerifyNameInteractor());
    Get.lazyPut(() => SaveIdentityCacheOnWebInteractor(
      Get.find<IdentityCreatorRepository>()
    ));
  }
  
  @override
  void bindingsRepository() {
    Get.lazyPut<IdentityCreatorRepository>(() => Get.find<IdentityCreatorRepositoryImpl>());
  }
  
  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => IdentityCreatorRepositoryImpl(
      Get.find<IdentityCreatorDataSource>()
    ));
  }
}