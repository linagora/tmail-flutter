import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_user_preference_notifier.dart';
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
        driveAttachmentUserPreferenceProvider.overrideWith(
          (ref) async => userPreferenceDefault,
        ),
      ],
    );

Future<Uri?> _awaitedUri(ProviderContainer c) async {
  await c.read(driveAttachmentUserPreferenceProvider.future);
  return c.read(driveAttachmentUriValueProvider).value;
}

ProviderContainer _makeAllMetContainer() => _makeContainer(
      enabledDefault: true,
      fqdnDefault: 'https://workplace.example.com',
      userPreferenceDefault: true,
    );

void _setEnabled(ProviderContainer c, bool? value) =>
    c.read(driveAttachmentEnabledProvider.notifier).setEnabled(value);

void _setFqdn(ProviderContainer c, String? value) =>
    c.read(workplaceFqdnProvider.notifier).setFqdn(value);

class _StubEnabledNotifier extends DriveAttachmentEnabledNotifier {
  _StubEnabledNotifier(this._initial);
  final bool _initial;
  @override
  bool build() => _initial;
  @override
  void setEnabled(bool? value) => state = value ?? false;
}

class _StubFqdnNotifier extends WorkplaceFqdnNotifier {
  _StubFqdnNotifier(this._initial);
  final String? _initial;
  @override
  String? build() => _initial;
  @override
  void setFqdn(String? value) => state = value;
}

class _MutableUserPref {
  bool value;
  _MutableUserPref(this.value);
}

ProviderContainer _makeContainerWithMutablePref({
  bool enabledDefault = true,
  String? fqdnDefault,
  required _MutableUserPref pref,
}) =>
    ProviderContainer(
      overrides: [
        driveAttachmentEnabledProvider.overrideWith(
          () => _StubEnabledNotifier(enabledDefault),
        ),
        workplaceFqdnProvider.overrideWith(
          () => _StubFqdnNotifier(fqdnDefault),
        ),
        driveAttachmentUserPreferenceProvider.overrideWith(
          (ref) async => pref.value,
        ),
      ],
    );

void main() {
  group('driveAttachmentUriValueProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('null when all conditions unset (defaults)', () async {
      container = _makeContainer();
      expect(await _awaitedUri(container), isNull);
    });

    test('null when enabled=true and fqdn set but user preference off', () async {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: 'https://workplace.example.com',
      );
      expect(await _awaitedUri(container), isNull);
    });

    test('null when enabled=true and user preference on but fqdn=null', () async {
      container = _makeContainer(
        enabledDefault: true,
        userPreferenceDefault: true,
      );
      expect(await _awaitedUri(container), isNull);
    });

    test('null when fqdn set and user preference on but enabled=false', () async {
      container = _makeContainer(
        fqdnDefault: 'https://workplace.example.com',
        userPreferenceDefault: true,
      );
      expect(await _awaitedUri(container), isNull);
    });

    test('non-null when all three conditions met', () async {
      container = _makeAllMetContainer();
      expect(await _awaitedUri(container), isNotNull);
    });

    test('null when fqdn reset to null after all conditions met', () async {
      container = _makeAllMetContainer();
      await _awaitedUri(container);
      _setFqdn(container, null);
      expect(container.read(driveAttachmentUriValueProvider).value, isNull);
    });

    test('null when enabled reset to false after all conditions met', () async {
      container = _makeAllMetContainer();
      await _awaitedUri(container);
      _setEnabled(container, false);
      expect(container.read(driveAttachmentUriValueProvider).value, isNull);
    });

    test('null when enabled=null (treated as false)', () async {
      container = _makeContainer(
        fqdnDefault: 'https://workplace.example.com',
        userPreferenceDefault: true,
      );
      await _awaitedUri(container);
      _setEnabled(container, null);
      expect(container.read(driveAttachmentUriValueProvider).value, isNull);
    });

    test('non-null when user preference toggled from false to true', () async {
      final pref = _MutableUserPref(false);
      container = _makeContainerWithMutablePref(
        fqdnDefault: 'https://workplace.example.com',
        pref: pref,
      );
      await _awaitedUri(container);
      expect(container.read(driveAttachmentUriValueProvider).value, isNull);

      pref.value = true;
      container.invalidate(driveAttachmentUserPreferenceProvider);
      await container.read(driveAttachmentUserPreferenceProvider.future);

      expect(container.read(driveAttachmentUriValueProvider).value, isNotNull);
    });

    test('null when user preference toggled from true to false', () async {
      final pref = _MutableUserPref(true);
      container = _makeContainerWithMutablePref(
        fqdnDefault: 'https://workplace.example.com',
        pref: pref,
      );
      await _awaitedUri(container);
      expect(container.read(driveAttachmentUriValueProvider).value, isNotNull);

      pref.value = false;
      container.invalidate(driveAttachmentUserPreferenceProvider);
      await container.read(driveAttachmentUserPreferenceProvider.future);

      expect(container.read(driveAttachmentUriValueProvider).value, isNull);
    });
  });
}
