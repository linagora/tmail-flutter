import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';

/// Records the config a [LocalPreferenceOption] tried to persist.
class FakeUpdateLocalSettingsInteractor implements UpdateLocalSettingsInteractor {
  PreferencesConfig? captured;

  @override
  Stream<Either<Failure, Success>> execute(PreferencesConfig preferencesConfig) {
    captured = preferencesConfig;
    return const Stream<Either<Failure, Success>>.empty();
  }
}

/// Records the payload a [ServerPreferenceOption] tried to persist.
class FakeUpdateServerSettingInteractor implements UpdateServerSettingInteractor {
  TMailServerSettingOptions? captured;

  @override
  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    TMailServerSettingOptions newSettingOption,
  ) {
    captured = newSettingOption;
    return const Stream<Either<Failure, Success>>.empty();
  }
}

PreferencesContext preferencesContext({
  TMailServerSettingOptions? serverOptions,
  PreferencesSetting? localSettings,
  bool isAIScribeAvailable = false,
  bool isAICapabilitySupported = false,
  bool isLabelVisibilityEnabled = false,
}) =>
    (
      session: null,
      accountId: null,
      serverOptions: serverOptions,
      localSettings: localSettings ?? PreferencesSetting([]),
      isAIScribeAvailable: isAIScribeAvailable,
      isAICapabilitySupported: isAICapabilitySupported,
      isLabelVisibilityEnabled: isLabelVisibilityEnabled,
    );
