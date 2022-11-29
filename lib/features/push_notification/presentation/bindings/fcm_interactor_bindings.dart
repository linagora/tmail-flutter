import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/hive_fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/fcm_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_fcm_token_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_token_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/save_fcm_token_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class FcmInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<FCMDatasource>(() => Get.find<HiveFCMDatasourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => HiveFCMDatasourceImpl(
      Get.find<FCMCacheManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
    Get.lazyPut(() => ThreadDataSourceImpl(
      Get.find<ThreadAPI>(),
      Get.find<ThreadIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => DeleteFCMTokenCacheInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => SaveFCMTokenCacheInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetFCMTokenCacheInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetStoredEmailDeliveryStateInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreEmailDeliveryStateInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetEmailChangesToPushNotificationInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => GetEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => DeleteEmailStateToRefreshInteractor(Get.find<FCMRepositoryImpl>()));
    Get.lazyPut(() => StoreDeviceIdInteractor(Get.find<FCMRepositoryImpl>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<FCMRepository>(() => Get.find<FCMRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => FCMRepositoryImpl(
      Get.find<FCMDatasource>(),
      Get.find<ThreadDataSource>()
    ));
  }
}
