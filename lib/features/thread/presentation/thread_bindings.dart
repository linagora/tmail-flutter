import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/local_thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/clean_and_get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class ThreadBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.put(ThreadController(
      Get.find<GetEmailsInMailboxInteractor>(),
      Get.find<RefreshChangesEmailsInMailboxInteractor>(),
      Get.find<LoadMoreEmailsInMailboxInteractor>(),
      Get.find<SearchEmailInteractor>(),
      Get.find<SearchMoreEmailInteractor>(),
      Get.find<GetEmailByIdInteractor>(),
      Get.find<CleanAndGetEmailsInMailboxInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ThreadDataSourceImpl(
      Get.find<ThreadAPI>(),
      Get.find<ThreadIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => LocalThreadDataSourceImpl(
      Get.find<EmailCacheManager>(),
      Get.find<CachingManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => RefreshChangesEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => LoadMoreEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => SearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => SearchMoreEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => GetEmailByIdInteractor(Get.find<ThreadRepository>(), Get.find<EmailRepository>()));
    Get.lazyPut(() => CleanAndGetEmailsInMailboxInteractor(
      Get.find<ThreadRepository>(),
      Get.find<GetEmailsInMailboxInteractor>(),
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ThreadRepositoryImpl(
        {
          DataSourceType.network: Get.find<ThreadDataSource>(),
          DataSourceType.local: Get.find<LocalThreadDataSourceImpl>()
        },
        Get.find<StateDataSource>()
    ));
  }
}