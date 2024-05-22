import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/notification_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/notification_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/notification_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/attempt_toggle_system_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class NotificationBinding extends BaseBindings {
  @override
  void bindingsController() {
    Get.put(NotificationController(
      Get.find<GetAppNotificationSettingCacheInteractor>(),
      Get.find<ToggleAppNotificationSettingCacheInteractor>(),
      Get.find<AttemptToggleSystemNotificationSettingInteractor>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<NotificationDataSource>(
      () => Get.find<NotificationDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => NotificationDataSourceImpl(
      Get.find<NotificationSettingCacheManager>(),
      Get.find<CacheExceptionThrower>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAppNotificationSettingCacheInteractor(
      Get.find<NotificationRepository>()));
    Get.lazyPut(() => ToggleAppNotificationSettingCacheInteractor(
      Get.find<NotificationRepository>()));
    Get.lazyPut(() => AttemptToggleSystemNotificationSettingInteractor(
      Get.find<NotificationRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<NotificationRepository>(
      () => Get.find<NotificationRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => NotificationRepositoryImpl(
      Get.find<NotificationDataSource>()));
  }
}