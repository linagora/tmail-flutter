import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

/// Responsible for loading local settings from cache on startup and pushing
/// the result into [localSettingsNotifierProvider] so all Riverpod consumers
/// receive the initial value automatically.
class LocalSettingsService extends GetxService {
  final GetLocalSettingsInteractor _getLocalSettingsInteractor;

  LocalSettingsService(this._getLocalSettingsInteractor);

  @override
  void onInit() {
    super.onInit();
    _loadInitialSettings();
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
                .read(localSettingsNotifierProvider.notifier)
                .update(success.preferencesSetting);
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
