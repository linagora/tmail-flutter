import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';

part 'local_cache_managers_providers.g.dart';

@riverpod
SharedPreferences sharedPreferences(Ref ref) => Get.find<SharedPreferences>();

@riverpod
PreferencesSettingManager preferencesSettingManager(Ref ref) =>
    PreferencesSettingManager(ref.watch(sharedPreferencesProvider));

@riverpod
LanguageCacheManager languageCacheManager(Ref ref) =>
    LanguageCacheManager(ref.watch(sharedPreferencesProvider));
