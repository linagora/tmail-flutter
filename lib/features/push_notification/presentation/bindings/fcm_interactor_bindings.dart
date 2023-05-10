import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/cache_fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/fcm_api.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/fcm_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_remove_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_subscription_local_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_new_receive_email_from_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/register_new_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_subscription_interator.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class FcmInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<FCMDatasource>(() => Get.find<FcmDatasourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CacheFCMDatasourceImpl(
      Get.find<FCMCacheManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
    Get.lazyPut(() => FcmDatasourceImpl(
      Get.find<FcmApi>(),
      Get.find<RemoteExceptionThrower>(),
    ));
    Get.lazyPut(() => ThreadDataSourceImpl(
      Get.find<ThreadAPI>(),
      Get.find<ThreadIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()
    ));
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailDataSourceImpl(
      Get.find<EmailAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<DioClient>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheClient>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailHiveCacheDataSourceImpl(
      Get.find<DetailedEmailCacheManager>(),
      Get.find<DetailedEmailCacheWorkerQueue>(),
      Get.find<FileUtils>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetStoredEmailDeliveryStateInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreEmailDeliveryStateInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetEmailChangesToPushNotificationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetEmailChangesToRemoveNotificationInteractor(
      Get.find<FCMRepositoryImpl>(),
      Get.find<EmailRepository>()));
    Get.lazyPut(() => StoreEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DeleteEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetFirebaseSubscriptionInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => RegisterNewTokenInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreMailboxStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetMailboxStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreSubscriptionInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetFCMSubscriptionLocalInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DestroySubscriptionInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetMailboxesNotPutNotificationsInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetNewReceiveEmailFromNotificationInteractor(
      Get.find<FCMRepositoryImpl>(),
      Get.find<EmailRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<FCMRepository>(() => Get.find<FCMRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => FCMRepositoryImpl(
      {
        DataSourceType.local: Get.find<CacheFCMDatasourceImpl>(),
        DataSourceType.network: Get.find<FCMDatasource>(),
      },
      Get.find<ThreadDataSource>(),
      {
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>(),
        DataSourceType.network: Get.find<MailboxDataSource>(),
      },
    ));
    Get.lazyPut(() => EmailRepositoryImpl(
      {
        DataSourceType.network: Get.find<EmailDataSource>(),
        DataSourceType.hiveCache: Get.find<EmailHiveCacheDataSourceImpl>()
      },
      Get.find<HtmlDataSource>(),
      Get.find<StateDataSource>()));
  }
}
