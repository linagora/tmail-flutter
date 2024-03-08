import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/always_read_receipt/always_read_receipt_controller.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class AlwaysReadReceiptBindings extends BaseBindings {
  @override
  void bindingsController() {
    Get.put(AlwaysReadReceiptController(
      Get.find<GetAlwaysReadReceiptSettingInteractor>(),
      Get.find<UpdateAlwaysReadReceiptSettingInteractor>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ServerSettingsDataSource>(() => Get.find<RemoteServerSettingsDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(), 
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAlwaysReadReceiptSettingInteractor(Get.find<ServerSettingsRepository>()));
    Get.lazyPut(() => UpdateAlwaysReadReceiptSettingInteractor(Get.find<ServerSettingsRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ServerSettingsRepository>(() => Get.find<ServerSettingsRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ServerSettingsRepositoryImpl(Get.find<ServerSettingsDataSource>()));
  }
}