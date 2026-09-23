import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:core/utils/sentry/sentry_reporting_consent.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Lets a user opt in to sending error reports, so support can diagnose bugs
/// that cannot be reproduced internally.
///
/// The stored value is tri-state: `null` falls back to the instance default,
/// which is why the displayed state also consults [SentryReportingConsent].
class SentryReportingPreferenceOption extends ServerPreferenceOption {
  SentryReportingPreferenceOption(
    UpdateServerSettingInteractor updateServerSettingInteractor, {
    SentryReportingConsent? sentryReportingConsent,
  })  : _sentryReportingConsent = sentryReportingConsent ?? SentryManager.instance,
        super(updateServerSettingInteractor);

  final SentryReportingConsent _sentryReportingConsent;

  @override
  String get id => 'sentry-reporting';

  @override
  String title(AppLocalizations l) => l.errorReporting;

  @override
  String explanation(AppLocalizations l) => l.errorReportingSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.errorReportingToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.serverOptions?.sentryUserOptIn ??
      _sentryReportingConsent.isSentryReportingAllowed;

  /// Hidden until Sentry actually initialised — with no SDK running the toggle
  /// would have nothing to turn on or off.
  ///
  /// Decided here rather than by leaving the option out of the registry: the
  /// registry is built once and cached, so a user opening this screen before
  /// Sentry finishes starting would never see the toggle again.
  @override
  bool isAvailable(PreferencesContext context) =>
      context.serverOptions != null && _sentryReportingConsent.isSentryAvailable;

  @override
  TMailServerSettingOptions applyTo(
    TMailServerSettingOptions current, {
    required bool enabled,
  }) =>
      current.withSentryUserOptIn(enabled);
}
