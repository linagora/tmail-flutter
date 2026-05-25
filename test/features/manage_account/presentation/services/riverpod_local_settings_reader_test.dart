import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/local_settings_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/services/riverpod_local_settings_reader.dart';

ProviderContainer _makeContainer() => ProviderContainer();

void main() {
  group('RiverpodLocalSettingsReader', () {
    late ProviderContainer container;
    late RiverpodLocalSettingsReader reader;

    setUp(() {
      container = _makeContainer();
      reader = RiverpodLocalSettingsReader(container);
    });

    tearDown(() {
      container.dispose();
    });

    test('currentSettings returns initial PreferencesSetting', () {
      expect(reader.currentSettings, equals(PreferencesSetting.initial()));
    });

    test('listen notifies onChange when provider changes', () {
      PreferencesSetting? received;
      reader.listen((next) => received = next);

      final updated = PreferencesSetting([
        ThreadDetailConfig(isEnabled: true),
        CollapseThreadConfig(isEnabled: true),
      ]);
      container.read(localSettingsNotifierProvider.notifier).update(updated);

      expect(received, equals(updated));
    });

    test('cancel stops future notifications', () {
      PreferencesSetting? received;
      final cancel = reader.listen((next) => received = next);

      cancel();

      container.read(localSettingsNotifierProvider.notifier).update(
        PreferencesSetting([ThreadDetailConfig(isEnabled: true)]),
      );

      expect(received, isNull);
    });

    test('isCollapseThreadsEnabled is true when thread and collapse both enabled', () {
      container.read(localSettingsNotifierProvider.notifier).update(
        PreferencesSetting([
          ThreadDetailConfig(isEnabled: true),
          CollapseThreadConfig(isEnabled: true),
        ]),
      );

      expect(reader.isCollapseThreadsEnabled, isTrue);
    });

    test('isCollapseThreadsEnabled is false when thread is disabled', () {
      container.read(localSettingsNotifierProvider.notifier).update(
        PreferencesSetting([
          ThreadDetailConfig(isEnabled: false),
          CollapseThreadConfig(isEnabled: true),
        ]),
      );

      expect(reader.isCollapseThreadsEnabled, isFalse);
    });

    test('isCollapseThreadsEnabled is false when collapse is disabled', () {
      container.read(localSettingsNotifierProvider.notifier).update(
        PreferencesSetting([
          ThreadDetailConfig(isEnabled: true),
          CollapseThreadConfig(isEnabled: false),
        ]),
      );

      expect(reader.isCollapseThreadsEnabled, isFalse);
    });
  });
}
