import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/main/providers/experimental_preferences_revealed_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_user_preference_notifier.dart';

/// Responsible for loading local settings from cache on startup and pushing
/// the result into [localSettingsProvider] so all Riverpod consumers
/// receive the initial value automatically.
class LocalSettingsService extends GetxService {
  final GetLocalSettingsInteractor _getLocalSettingsInteractor;

  LocalSettingsService(this._getLocalSettingsInteractor);

  @override
  void onInit() {
    super.onInit();
    _loadInitialSettings();
    // Warm up experiment reveal provider so it reads from storage at startup.
    appProviderContainer.read(experimentalPreferencesRevealedProvider);
  }

  Future<void> _loadInitialSettings() {
    return _getLocalSettingsInteractor.execute().last.then(
      (result) => result.fold(
        (failure) => logWarning(
          'LocalSettingsService::_loadInitialSettings:failure: $failure',
        ),
        (success) {
          if (success is GetLocalSettingsSuccess) {
            appProviderContainer
                .read(localSettingsProvider.notifier)
                .update(success.preferencesSetting);
            appProviderContainer.invalidate(driveAttachmentUserPreferenceProvider);
          }
        },
      ),
    ).catchError((error, stackTrace) {
      logWarning(
        'LocalSettingsService::_loadInitialSettings:error: $error | stackTrace: $stackTrace',
      );
    });
  }
}
