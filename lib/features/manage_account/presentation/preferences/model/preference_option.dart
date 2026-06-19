import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// A read-only snapshot of everything a [PreferenceOption] needs to render,
/// decide its visibility and persist a change.
///
/// It bundles both storage backends and the relevant capabilities so each
/// option — not an `isLocal` flag spread across the controller — owns the
/// decision of where its value lives and when it is shown.
typedef PreferencesContext = ({
  Session? session,
  AccountId? accountId,
  TMailServerSettingOptions? serverOptions,
  PreferencesSetting localSettings,
  bool isAIScribeAvailable,
  bool isAICapabilitySupported,
  bool isLabelVisibilityEnabled,
});

/// One user-facing preference toggle.
///
/// Each implementation owns the four facets that used to be scattered across
/// `PreferencesOptionType` (strings + read state), the controller (write
/// behaviour) and the view (visibility):
///  1. display strings,
///  2. current state,
///  3. visibility,
///  4. write behaviour.
abstract class PreferenceOption {
  /// Stable identifier, independent of ordering or storage backend.
  String get id;

  // facet 1 — display strings
  String title(AppLocalizations l);
  String explanation(AppLocalizations l);
  String toggleDescription(AppLocalizations l);

  // facet 2 — current state
  bool isEnabled(PreferencesContext context);

  // facet 3 — visibility
  bool isAvailable(PreferencesContext context);

  /// Whether this option is hidden until experimental preferences are revealed (7-tap).
  bool get isExperimental => false;

  // facet 4 — write behaviour
  /// [currentValue] is what the user sees now; toggling persists its negation.
  Stream<Either<Failure, Success>> toggle({
    required bool currentValue,
    required PreferencesContext context,
  });
}

/// Base for preferences backed by local settings.
abstract class LocalPreferenceOption extends PreferenceOption {
  LocalPreferenceOption(this.updateLocalSettingsInteractor);

  final UpdateLocalSettingsInteractor updateLocalSettingsInteractor;

  /// The config payload representing [enabled] for this option.
  PreferencesConfig buildConfig({required bool enabled});

  @override
  bool isAvailable(PreferencesContext context) =>
      context.localSettings.configs.isNotEmpty;

  @override
  Stream<Either<Failure, Success>> toggle({
    required bool currentValue,
    required PreferencesContext context,
  }) =>
      updateLocalSettingsInteractor.execute(buildConfig(enabled: !currentValue));
}

/// Base for preferences backed by JMAP server settings.
abstract class ServerPreferenceOption extends PreferenceOption {
  ServerPreferenceOption(this.updateServerSettingInteractor);

  final UpdateServerSettingInteractor updateServerSettingInteractor;

  /// Returns [current] with this option set to [enabled].
  TMailServerSettingOptions applyTo(
    TMailServerSettingOptions current, {
    required bool enabled,
  });

  @override
  bool isAvailable(PreferencesContext context) => context.serverOptions != null;

  @override
  Stream<Either<Failure, Success>> toggle({
    required bool currentValue,
    required PreferencesContext context,
  }) {
    final session = context.session;
    final accountId = context.accountId;
    final current = context.serverOptions;
    final isContextMissing = session == null || accountId == null || current == null;
    if (isContextMissing) {
      return Stream.value(
        Left(UpdateServerSettingFailure(NotFoundAccountIdException())),
      );
    }
    return updateServerSettingInteractor.execute(
      session,
      accountId,
      applyTo(current, enabled: !currentValue),
    );
  }
}
