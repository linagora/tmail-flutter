import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/enable_experimental_mode_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_experimental_mode_enabled_interactor.dart';
import 'package:tmail_ui_user/main/providers/cache_exception_thrower_provider.dart';
import 'package:tmail_ui_user/main/providers/shared_preferences_provider.dart';

final _languageCacheManagerProvider = Provider<LanguageCacheManager>(
  (ref) => LanguageCacheManager(ref.read(sharedPreferencesProvider)),
);

final _preferencesSettingManagerProvider = Provider<PreferencesSettingManager>(
  (ref) => PreferencesSettingManager(ref.read(sharedPreferencesProvider)),
);

final _manageAccountLocalDataSourceProvider = Provider<ManageAccountDataSource>(
  (ref) => ManageAccountDataSourceImpl(
    ref.read(_languageCacheManagerProvider),
    ref.read(_preferencesSettingManagerProvider),
    ref.read(cacheExceptionThrowerProvider),
  ),
);

final _manageAccountLocalRepositoryProvider = Provider<ManageAccountRepository>(
  (ref) => ManageAccountRepositoryImpl(ref.read(_manageAccountLocalDataSourceProvider)),
);

final getExperimentalModeEnabledProvider = Provider<GetExperimentalModeEnabledInteractor>(
  (ref) => GetExperimentalModeEnabledInteractor(ref.read(_manageAccountLocalRepositoryProvider)),
);

final enableExperimentalModeProvider = Provider<EnableExperimentalModeInteractor>(
  (ref) => EnableExperimentalModeInteractor(ref.read(_manageAccountLocalRepositoryProvider)),
);
