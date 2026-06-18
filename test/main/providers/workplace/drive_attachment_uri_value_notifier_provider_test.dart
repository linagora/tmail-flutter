import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/drive_attachment_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

ProviderContainer _makeContainer({
  bool enabledDefault = false,
  String? fqdnDefault,
  bool userPreferenceDefault = false,
}) =>
    ProviderContainer(
      overrides: [
        driveAttachmentEnabledProvider.overrideWith(
          () => _StubEnabledNotifier(enabledDefault),
        ),
        workplaceFqdnProvider.overrideWith(
          () => _StubFqdnNotifier(fqdnDefault),
        ),
        localSettingsProvider.overrideWith(
          () => _StubLocalSettingsNotifier(userPreferenceDefault),
        ),
      ],
    );

Uri? _currentUri(ProviderContainer c) =>
    c.read(driveAttachmentUriValueProvider).value;

ProviderContainer _makeAllMetContainer() => _makeContainer(
      enabledDefault: true,
      fqdnDefault: _kWorkplaceFqdn,
      userPreferenceDefault: true,
    );

void _setEnabled(ProviderContainer c, bool? value) =>
    c.read(driveAttachmentEnabledProvider.notifier).setEnabled(value);

void _setFqdn(ProviderContainer c, String? value) =>
    c.read(workplaceFqdnProvider.notifier).setFqdn(value);

void _setUserPref(ProviderContainer c, bool value) =>
    c.read(localSettingsProvider.notifier).update(
      PreferencesSetting([DriveAttachmentConfig(isEnabled: value)]),
    );

class _StubEnabledNotifier extends DriveAttachmentEnabledNotifier {
  _StubEnabledNotifier(this._initial);
  final bool _initial;
  @override
  bool build() => _initial;
  @override
  void setEnabled(bool? value) => state = value ?? true;
}

class _StubFqdnNotifier extends WorkplaceFqdnNotifier {
  _StubFqdnNotifier(this._initial);
  final String? _initial;
  @override
  String? build() => _initial;
  @override
  void setFqdn(String? value) => state = value;
}

class _StubLocalSettingsNotifier extends LocalSettingsNotifier {
  _StubLocalSettingsNotifier(this._initialPref);
  final bool _initialPref;
  @override
  PreferencesSetting build() =>
      PreferencesSetting([DriveAttachmentConfig(isEnabled: _initialPref)]);
}

const _kWorkplaceFqdn = 'https://workplace.example.com';

typedef _ToggleExpectation = ({
  Matcher beforeToggle,
  bool toggleTo,
  Matcher afterToggle,
});

void _testUserPrefToggle(
  ProviderContainer c,
  _ToggleExpectation expectation,
) {
  expect(_currentUri(c), expectation.beforeToggle);
  _setUserPref(c, expectation.toggleTo);
  expect(_currentUri(c), expectation.afterToggle);
}

void main() {
  group('driveAttachmentUriValueProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('null when all conditions unset (defaults)', () {
      container = _makeContainer();
      expect(_currentUri(container), isNull);
    });

    test('null when enabled=true and fqdn set but user preference off', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
      );
      expect(_currentUri(container), isNull);
    });

    test('null when enabled=true and user preference on but fqdn=null', () {
      container = _makeContainer(
        enabledDefault: true,
        userPreferenceDefault: true,
      );
      expect(_currentUri(container), isNull);
    });

    test('null when fqdn set and user preference on but enabled=false', () {
      container = _makeContainer(
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      expect(_currentUri(container), isNull);
    });

    test('non-null when all three conditions met', () {
      container = _makeAllMetContainer();
      expect(_currentUri(container), isNotNull);
    });

    test('null when fqdn reset to null after all conditions met', () {
      container = _makeAllMetContainer();
      _setFqdn(container, null);
      expect(_currentUri(container), isNull);
    });

    test('null when enabled reset to false after all conditions met', () {
      container = _makeAllMetContainer();
      _setEnabled(container, false);
      expect(_currentUri(container), isNull);
    });

    test('non-null when enabled=null (treated as true)', () {
      container = _makeContainer(
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      _setEnabled(container, null);
      expect(_currentUri(container), Uri.parse(_kWorkplaceFqdn));
    });

    test('non-null when user preference toggled from false to true', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
      );
      _testUserPrefToggle(
        container,
        (beforeToggle: isNull, toggleTo: true, afterToggle: isNotNull),
      );
    });

    test('null when user preference toggled from true to false', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      _testUserPrefToggle(
        container,
        (beforeToggle: isNotNull, toggleTo: false, afterToggle: isNull),
      );
    });
  });
}
