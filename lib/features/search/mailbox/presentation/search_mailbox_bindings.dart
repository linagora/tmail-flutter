
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subaddressing_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class SearchMailboxBindings extends BaseBindings {

  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => TreeBuilder());
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => SearchMailboxController(
      Get.find<SearchMailboxInteractor>(),
      Get.find<RenameMailboxInteractor>(),
      Get.find<MoveMailboxInteractor>(),
      Get.find<DeleteMultipleMailboxInteractor>(),
      Get.find<SubscribeMailboxInteractor>(),
      Get.find<SubscribeMultipleMailboxInteractor>(),
      Get.find<CreateNewMailboxInteractor>(),
      Get.find<SubaddressingInteractor>(),
      Get.find<TreeBuilder>(),
      Get.find<VerifyNameInteractor>(),
      Get.find<GetAllMailboxInteractor>(),
      Get.find<RefreshAllMailboxInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()
    ));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => RefreshAllMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => RenameMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => MoveMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => DeleteMultipleMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => VerifyNameInteractor());
    Get.lazyPut(() => SearchMailboxInteractor());
    Get.lazyPut(() => SubscribeMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => SubscribeMultipleMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => CreateNewMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => SubaddressingInteractor(Get.find<MailboxRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>()
    ));
  }

  void disposeBindings() {
    Get.delete<SearchMailboxController>();
  }
}