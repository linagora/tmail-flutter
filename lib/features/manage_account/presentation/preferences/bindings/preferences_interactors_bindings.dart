import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/local_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
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
    Get.lazyPut<ManageAccountDataSource>(
      () => Get.find<ManageAccountDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => ManageAccountDataSourceImpl(
      Get.find<LanguageCacheManager>(),
      Get.find<LocalSettingCacheManager>(),
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
      () => SaveLanguageInteractor(Get.find<ManageAccountRepository>(tag: composerId)),
      tag: composerId,
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ServerSettingsRepository>(
      () => Get.find<ServerSettingsRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ManageAccountRepository>(
      () => Get.find<ManageAccountRepositoryImpl>(tag: composerId),
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
      () => ManageAccountRepositoryImpl(Get.find<ManageAccountDataSource>(tag: composerId)),
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
    
    Get.delete<ManageAccountDataSourceImpl>(tag: composerId);
    Get.delete<ManageAccountDataSource>(tag: composerId);
    Get.delete<ManageAccountRepositoryImpl>(tag: composerId);
    Get.delete<ManageAccountRepository>(tag: composerId);
    Get.delete<SaveLanguageInteractor>(tag: composerId);
  }
}