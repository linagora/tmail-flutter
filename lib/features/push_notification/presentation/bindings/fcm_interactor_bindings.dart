import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_local_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_session_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/print_file_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_list_detailed_email_by_id_interator.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_list_new_email_interator.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/cache_fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/fcm_api.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/fcm_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_firebase_registration_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_remove_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_registration_by_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_new_receive_email_from_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/register_new_firebase_registration_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_firebase_registration_interator.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/update_firebase_registration_token_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class FcmInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<FCMDatasource>(() => Get.find<FcmDatasourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<PrintFileDataSource>(() => Get.find<PrintFileDataSourceImpl>());
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
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => PrintFileDataSourceImpl(
      Get.find<PrintUtils>(),
      Get.find<ImagePaths>(),
      Get.find<FileUtils>(),
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => EmailHiveCacheDataSourceImpl(
      Get.find<NewEmailCacheManager>(),
      Get.find<OpenedEmailCacheManager>(),
      Get.find<NewEmailCacheWorkerQueue>(),
      Get.find<OpenedEmailCacheWorkerQueue>(),
      Get.find<EmailCacheManager>(),
      Get.find<SendingEmailCacheManager>(),
      Get.find<FileUtils>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailLocalStorageDataSourceImpl(
      Get.find<LocalStorageManager>(),
      Get.find<PreviewEmlFileUtils>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailSessionStorageDatasourceImpl(
      Get.find<SessionStorageManager>(),
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
    Get.lazyPut(() => GetFirebaseRegistrationByDeviceIdInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => RegisterNewFirebaseRegistrationTokenInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreMailboxStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetMailboxStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreFirebaseRegistrationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetStoredFirebaseRegistrationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DestroyFirebaseRegistrationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => UpdateFirebaseRegistrationTokenInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DeleteFirebaseRegistrationCacheInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DestroyFirebaseRegistrationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetMailboxesNotPutNotificationsInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetNewReceiveEmailFromNotificationInteractor(
      Get.find<FCMRepositoryImpl>(),
      Get.find<EmailRepository>()));
    Get.lazyPut(() => GetListDetailedEmailByIdInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => StoreListNewEmailInteractor(Get.find<EmailRepository>()));
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
        DataSourceType.hiveCache: Get.find<EmailHiveCacheDataSourceImpl>(),
        DataSourceType.local: Get.find<EmailLocalStorageDataSourceImpl>(),
        DataSourceType.session: Get.find<EmailSessionStorageDatasourceImpl>(),
      },
      Get.find<HtmlDataSource>(),
      Get.find<StateDataSource>(),
      Get.find<PrintFileDataSource>()));
  }
}
