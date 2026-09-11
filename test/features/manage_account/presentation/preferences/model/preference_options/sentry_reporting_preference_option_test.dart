import 'package:core/utils/sentry/sentry_reporting_consent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options/sentry_reporting_preference_option.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';

import 'sentry_reporting_preference_option_test.mocks.dart';

class _FakeSentryReportingConsent implements SentryReportingConsent {
  _FakeSentryReportingConsent({
    this.isSentryAvailable = true,
    bool reportingDefault = false,
  }) : _reportingDefault = reportingDefault;

  @override
  final bool isSentryAvailable;

  bool _reportingDefault;
  bool? _consent;

  @override
  bool get isSentryReportingAllowed => _consent ?? _reportingDefault;

  @override
  void setSentryReportingDefault(bool allowed) => _reportingDefault = allowed;

  @override
  void setSentryReportingConsent(bool? consent) => _consent = consent;
}

PreferencesContext _context({TMailServerSettingOptions? serverOptions}) => (
      session: null,
      accountId: null,
      serverOptions: serverOptions,
      localSettings: PreferencesSetting.initial(),
      isAIScribeAvailable: false,
      isAICapabilitySupported: false,
      isLabelVisibilityEnabled: false,
    );

@GenerateNiceMocks([MockSpec<UpdateServerSettingInteractor>()])
void main() {
  late MockUpdateServerSettingInteractor updateServerSetting;

  setUp(() => updateServerSetting = MockUpdateServerSettingInteractor());

  SentryReportingPreferenceOption buildOption({
    bool isSentryAvailable = true,
    bool reportingDefault = false,
  }) =>
      SentryReportingPreferenceOption(
        updateServerSetting,
        sentryReportingConsent: _FakeSentryReportingConsent(
          isSentryAvailable: isSentryAvailable,
          reportingDefault: reportingDefault,
        ),
      );

  group('SentryReportingPreferenceOption', () {
    group('isEnabled', () {
      test('reflects an explicit opt-in', () {
        final option = buildOption(reportingDefault: false);

        expect(
          option.isEnabled(_context(
            serverOptions: TMailServerSettingOptions(sentryUserOptIn: true),
          )),
          isTrue,
        );
      });

      test('reflects an explicit opt-out even when the instance opts in by default', () {
        final option = buildOption(reportingDefault: true);

        expect(
          option.isEnabled(_context(
            serverOptions: TMailServerSettingOptions(sentryUserOptIn: false),
          )),
          isFalse,
        );
      });

      test('falls back to the instance default when the user never chose', () {
        final context = _context(serverOptions: TMailServerSettingOptions());

        expect(buildOption(reportingDefault: false).isEnabled(context), isFalse);
        expect(buildOption(reportingDefault: true).isEnabled(context), isTrue);
      });
    });

    group('isAvailable', () {
      test('is hidden while server settings are unknown', () {
        expect(buildOption().isAvailable(_context()), isFalse);
      });

      test('stays hidden while Sentry has not started, and appears once it has', () {
        final context = _context(serverOptions: TMailServerSettingOptions());

        // The registry is built once and cached, so this must not be decided
        // at registration time.
        expect(buildOption(isSentryAvailable: false).isAvailable(context), isFalse);
        expect(buildOption(isSentryAvailable: true).isAvailable(context), isTrue);
      });

      test('is shown once server settings are known', () {
        expect(
          buildOption().isAvailable(
            _context(serverOptions: TMailServerSettingOptions()),
          ),
          isTrue,
        );
      });
    });

    group('unknown server settings', () {
      test('shows the state in effect rather than resetting it', () {
        final option = buildOption(reportingDefault: true);

        // Server settings failed to load: nothing is known about the choice.
        expect(option.isEnabled(_context()), isTrue);
      });
    });

    group('applyTo', () {
      test('writes the opt-in without dropping other options', () {
        final updated = buildOption().applyTo(
          TMailServerSettingOptions(alwaysReadReceipts: true),
          enabled: true,
        );

        expect(updated.sentryUserOptIn, isTrue);
        expect(updated.alwaysReadReceipts, isTrue);
      });

      test('writes the opt-out over a previous opt-in', () {
        final updated = buildOption().applyTo(
          TMailServerSettingOptions(sentryUserOptIn: true),
          enabled: false,
        );

        expect(updated.sentryUserOptIn, isFalse);
      });
    });
  });
}
