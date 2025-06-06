import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/preferences_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/preferences_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/preferences_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/preferences_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
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
    Get.lazyPut<PreferencesDataSource>(
      () => Get.find<PreferencesDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => PreferencesDataSourceImpl(
      Get.find<LanguageCacheManager>(),
      Get.find<CacheExceptionThrower>(),
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
    Get.lazyPut(
      () => SaveLanguageInteractor(Get.find<PreferencesRepository>(tag: composerId)),
      tag: composerId,
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ServerSettingsRepository>(
      () => Get.find<ServerSettingsRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<PreferencesRepository>(
      () => Get.find<PreferencesRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ServerSettingsRepositoryImpl(Get.find<ServerSettingsDataSource>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => PreferencesRepositoryImpl(Get.find<PreferencesDataSource>(tag: composerId)),
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
    
    Get.delete<PreferencesDataSourceImpl>(tag: composerId);
    Get.delete<PreferencesDataSource>(tag: composerId);
    Get.delete<PreferencesRepositoryImpl>(tag: composerId);
    Get.delete<PreferencesRepository>(tag: composerId);
    Get.delete<SaveLanguageInteractor>(tag: composerId);
  }
}