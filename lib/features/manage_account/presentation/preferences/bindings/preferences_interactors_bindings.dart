import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class PreferencesInteractorsBindings extends InteractorsBindings {

  final String? composerId;

  PreferencesInteractorsBindings({this.composerId});

  @override
  void bindingsDataSource() {
    Get.lazyPut<ServerSettingsDataSource>(
      () => Get.find<RemoteServerSettingsDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => GetServerSettingInteractor(Get.find<ServerSettingsRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => UpdateServerSettingInteractor(Get.find<ServerSettingsRepository>(tag: composerId)),
      tag: composerId,
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ServerSettingsRepository>(
      () => Get.find<ServerSettingsRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ServerSettingsRepositoryImpl(Get.find<ServerSettingsDataSource>(tag: composerId)),
      tag: composerId,
    );
  }

  void dispose() {
    Get.delete<RemoteServerSettingsDataSourceImpl>(tag: composerId);
    Get.delete<ServerSettingsDataSource>(tag: composerId);
    Get.delete<ServerSettingsRepositoryImpl>(tag: composerId);
    Get.delete<ServerSettingsRepository>(tag: composerId);
    Get.delete<UpdateServerSettingInteractor>(tag: composerId);
    Get.delete<GetServerSettingInteractor>(tag: composerId);
  }
}