import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_to_server_settings_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';

class SaveLanguageToServerSettingsInteractor {
  const SaveLanguageToServerSettingsInteractor(this._serverSettingsRepository);

  final ServerSettingsRepository _serverSettingsRepository;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Locale locale,
  ) async* {
    try {
      yield Right(SavingLanguageToServerSettings());
      final currentSettings = await _serverSettingsRepository.getServerSettings(accountId);
      final newSettings = TMailServerSettings(
        id: currentSettings.id,
        settings: currentSettings.settings?.copyWith(
          language: locale.languageCode,
        ) ?? TMailServerSettingOptions(language: locale.languageCode),
      );
      await _serverSettingsRepository.updateServerSettings(
        accountId,
        TMailServerSettings(settings: newSettings.settings),
      );
      yield Right(SaveLanguageToServerSettingsSuccess(locale));
    } catch (e) {
      logError('SaveLanguageToServerSettingsInteractor::execute(): $e');
      yield Left(SaveLanguageToServerSettingsFailure(exception: e));
    }
  }
}