import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/notification_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/notification_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/permissions/notification_permission_service.dart';

class NotificationBinding extends BaseBindings {
  @override
  void bindingsController() {
    Get.put(NotificationController(
      Get.find<GetNotificationSettingInteractor>(),
      Get.find<ToggleNotificationSettingInteractor>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<NotificationDataSource>(
      () => Get.find<NotificationDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => NotificationDataSourceImpl(
      Get.find<NotificationPermissionService>(),
      Get.find<CacheExceptionThrower>()
    ));
  }

  @override
  void dependencies() {
    Get.lazyPut(() => NotificationPermissionService());
    super.dependencies();
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetNotificationSettingInteractor(
      Get.find<NotificationRepository>()));
    Get.lazyPut(() => ToggleNotificationSettingInteractor(
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

  void close() {
    Get.delete<NotificationController>();
    Get.delete<GetNotificationSettingInteractor>();
    Get.delete<ToggleNotificationSettingInteractor>();
    Get.delete<NotificationRepository>();
    Get.delete<NotificationRepositoryImpl>();
    Get.delete<NotificationDataSource>();
    Get.delete<NotificationDataSourceImpl>();
    Get.delete<NotificationPermissionService>();
  }
}