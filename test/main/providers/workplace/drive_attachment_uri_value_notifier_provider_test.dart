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

bool _isFakeUri(Uri? uri) => uri?.scheme == 'data';
bool _isRealUri(Uri? uri) => uri != null && !_isFakeUri(uri);

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

void main() {
  group('driveAttachmentUriValueProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('fake data URI when all conditions unset (defaults)', () {
      container = _makeContainer();
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('fake data URI when enabled=true and fqdn set but user preference off', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
      );
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('fake data URI when enabled=true and user preference on but fqdn=null', () {
      container = _makeContainer(
        enabledDefault: true,
        userPreferenceDefault: true,
      );
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('fake data URI when fqdn set and user preference on but enabled=false', () {
      container = _makeContainer(
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('real URI when all three conditions met', () {
      container = _makeAllMetContainer();
      expect(_isRealUri(_currentUri(container)), isTrue);
    });

    test('fake data URI when fqdn reset to null after all conditions met', () {
      container = _makeAllMetContainer();
      _setFqdn(container, null);
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('fake data URI when enabled reset to false after all conditions met', () {
      container = _makeAllMetContainer();
      _setEnabled(container, false);
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });

    test('real URI when enabled=null (treated as true)', () {
      container = _makeContainer(
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      _setEnabled(container, null);
      expect(_currentUri(container), Uri.parse(_kWorkplaceFqdn));
    });

    test('transitions from fake to real URI when user preference toggled from false to true', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
      );
      expect(_isFakeUri(_currentUri(container)), isTrue);
      _setUserPref(container, true);
      expect(_isRealUri(_currentUri(container)), isTrue);
    });

    test('transitions from real to fake URI when user preference toggled from true to false', () {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: _kWorkplaceFqdn,
        userPreferenceDefault: true,
      );
      expect(_isRealUri(_currentUri(container)), isTrue);
      _setUserPref(container, false);
      expect(_isFakeUri(_currentUri(container)), isTrue);
    });
  });
}
