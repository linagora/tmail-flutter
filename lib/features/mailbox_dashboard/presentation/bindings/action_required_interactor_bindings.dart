import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
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
import 'package:tmail_ui_user/features/thread/domain/usecases/get_count_unread_emails_in_folder_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class ActionRequiredInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => ThreadDataSourceImpl(
        Get.find<ThreadAPI>(),
        Get.find<ThreadIsolateWorker>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
    Get.lazyPut(
      () => LocalThreadDataSourceImpl(
        Get.find<EmailCacheManager>(),
        Get.find<CachingManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
    Get.lazyPut(
      () => StateDataSourceImpl(
        Get.find<StateCacheManager>(),
        Get.find<IOSSharingManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => GetCountUnreadEmailsInFolderInteractor(
        Get.find<ThreadRepository>(),
      ),
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ThreadRepositoryImpl(
        {
          DataSourceType.network: Get.find<ThreadDataSource>(),
          DataSourceType.local: Get.find<LocalThreadDataSourceImpl>()
        },
        Get.find<StateDataSource>(),
      ),
    );
  }
}
