import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/presentation/provider/drive_attachment_available_provider.dart';
import 'package:workplace/presentation/provider/drive_attachment_enabled_notifier.dart';
import 'package:workplace/presentation/provider/drive_attachment_user_preference_notifier.dart';
import 'package:workplace/presentation/provider/workplace_fqdn_notifier.dart';

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

bool _state(ProviderContainer c) => c.read(isDriveAttachmentAvailableProvider);

Future<bool> _awaitedState(ProviderContainer c) async {
  await c.read(driveAttachmentUserPreferenceProvider.future);
  return _state(c);
}

ProviderContainer _makeAllMetContainer() => _makeContainer(
      enabledDefault: true,
      fqdnDefault: 'workplace.example.com',
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

void main() {
  group('isDriveAttachmentAvailableProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('false when all conditions unset (defaults)', () async {
      container = _makeContainer();
      expect(await _awaitedState(container), isFalse);
    });

    test('false when enabled=true and fqdn set but user preference off', () async {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: 'workplace.example.com',
      );
      expect(await _awaitedState(container), isFalse);
    });

    test('false when enabled=true and user preference on but fqdn=null', () async {
      container = _makeContainer(
        enabledDefault: true,
        userPreferenceDefault: true,
      );
      expect(await _awaitedState(container), isFalse);
    });

    test('false when fqdn set and user preference on but enabled=false', () async {
      container = _makeContainer(
        fqdnDefault: 'workplace.example.com',
        userPreferenceDefault: true,
      );
      expect(await _awaitedState(container), isFalse);
    });

    test('false when user preference off but server conditions met', () async {
      container = _makeContainer(
        enabledDefault: true,
        fqdnDefault: 'workplace.example.com',
      );
      expect(await _awaitedState(container), isFalse);
    });

    test('true when all three conditions met', () async {
      container = _makeAllMetContainer();
      expect(await _awaitedState(container), isTrue);
    });

    test('false when fqdn reset to null after all conditions met', () async {
      container = _makeAllMetContainer();
      await _awaitedState(container);
      _setFqdn(container, null);
      expect(_state(container), isFalse);
    });

    test('false when enabled reset to false after all conditions met', () async {
      container = _makeAllMetContainer();
      await _awaitedState(container);
      _setEnabled(container, false);
      expect(_state(container), isFalse);
    });

    test('false when enabled=null (treated as false)', () async {
      container = _makeContainer(
        fqdnDefault: 'workplace.example.com',
        userPreferenceDefault: true,
      );
      await _awaitedState(container);
      _setEnabled(container, null);
      expect(_state(container), isFalse);
    });
  });
}
