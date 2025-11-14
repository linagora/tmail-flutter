import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/reactions/data/datasource/reactions_datasource.dart';
import 'package:tmail_ui_user/features/reactions/data/datasource_impl/reactions_datasource_impl.dart';
import 'package:tmail_ui_user/features/reactions/data/local/reaction_cache_manager.dart';
import 'package:tmail_ui_user/features/reactions/data/repository/reactions_repository_impl.dart';
import 'package:tmail_ui_user/features/reactions/domain/repository/reactions_repository.dart';
import 'package:tmail_ui_user/features/reactions/domain/usecase/get_recent_reactions_interactor.dart';
import 'package:tmail_ui_user/features/reactions/domain/usecase/store_recent_reactions_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class ReactionsInteractorBindings extends InteractorsBindings {
  final String? composerId;

  ReactionsInteractorBindings({this.composerId});

  @override
  void bindingsDataSource() {
    Get.lazyPut<ReactionsDatasource>(
      () => Get.find<ReactionsDatasourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => ReactionsDatasourceImpl(
        Get.find<ReactionsCacheManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
      tag: composerId,
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => GetRecentReactionsInteractor(Get.find<ReactionsRepository>(
        tag: composerId,
      )),
      tag: composerId,
    );
    Get.lazyPut(
      () => StoreRecentReactionsInteractor(Get.find<ReactionsRepository>(
        tag: composerId,
      )),
      tag: composerId,
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ReactionsRepository>(
      () => Get.find<ReactionsRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ReactionsRepositoryImpl(
        Get.find<ReactionsDatasource>(tag: composerId),
      ),
      tag: composerId,
    );
  }

  void dispose() {
    Get.delete<ReactionsDatasourceImpl>(tag: composerId);
    Get.delete<ReactionsDatasource>(tag: composerId);
    Get.delete<ReactionsRepositoryImpl>(tag: composerId);
    Get.delete<ReactionsRepository>(tag: composerId);
    Get.delete<GetRecentReactionsInteractor>(tag: composerId);
    Get.delete<StoreRecentReactionsInteractor>(tag: composerId);
  }
}
