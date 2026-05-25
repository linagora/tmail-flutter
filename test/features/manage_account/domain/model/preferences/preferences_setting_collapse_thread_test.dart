import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

void main() {
  group('PreferencesSetting.isCollapseThreadsEnabled', () {
    test('true when both thread and collapse are enabled', () {
      final s = PreferencesSetting([
        ThreadDetailConfig(isEnabled: true),
        CollapseThreadConfig(isEnabled: true),
      ]);
      expect(s.isCollapseThreadsEnabled, isTrue);
    });

    test('false when thread is disabled', () {
      final s = PreferencesSetting([
        ThreadDetailConfig(isEnabled: false),
        CollapseThreadConfig(isEnabled: true),
      ]);
      expect(s.isCollapseThreadsEnabled, isFalse);
    });

    test('false when collapse is disabled', () {
      final s = PreferencesSetting([
        ThreadDetailConfig(isEnabled: true),
        CollapseThreadConfig(isEnabled: false),
      ]);
      expect(s.isCollapseThreadsEnabled, isFalse);
    });

    test('false when both are disabled', () {
      final s = PreferencesSetting([
        ThreadDetailConfig(isEnabled: false),
        CollapseThreadConfig(isEnabled: false),
      ]);
      expect(s.isCollapseThreadsEnabled, isFalse);
    });
  });

  group('PreferencesSetting.collapseThreadConfig', () {
    test('returns CollapseThreadConfig when present in configs', () {
      final config = CollapseThreadConfig(isEnabled: true);
      final setting = PreferencesSetting([config]);

      expect(setting.collapseThreadConfig.isEnabled, isTrue);
    });

    test('returns initial (disabled) when CollapseThreadConfig is absent', () {
      final setting = PreferencesSetting([ThreadDetailConfig(isEnabled: true)]);

      expect(setting.collapseThreadConfig.isEnabled, isFalse);
    });

    test('initial() includes CollapseThreadConfig defaulting to disabled', () {
      final setting = PreferencesSetting.initial();

      expect(setting.collapseThreadConfig, isA<CollapseThreadConfig>());
      expect(setting.collapseThreadConfig.isEnabled, isFalse);
    });
  });
}
