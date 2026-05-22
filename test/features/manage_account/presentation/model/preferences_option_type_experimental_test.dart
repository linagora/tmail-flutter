import 'package:flutter_test/flutter_test.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';

// All options that are standard (not experimental) and top-level (no parent).
// collapseThread is the only exception: experimental + child.
final _standardTopLevelOptions = PreferencesOptionType.values
    .where((t) => t != PreferencesOptionType.collapseThread)
    .toList();

PreferencesVisibilityContext _ctx({
  bool isExperimentalEnabled = false,
  bool isAIScribeAvailable = false,
  bool isLabelVisibility = false,
  PreferencesSetting? localSettings,
}) => (
  settingOption: null,
  localSettings: localSettings ?? PreferencesSetting.initial(),
  isExperimentalEnabled: isExperimentalEnabled,
  isAIScribeAvailable: isAIScribeAvailable,
  isAICapabilitySupported: false,
  isLabelVisibility: isLabelVisibility,
);

PreferencesVisibilityContext _serverCtx({
  bool isAICapabilitySupported = false,
}) => (
  settingOption: TMailServerSettingOptions(),
  localSettings: PreferencesSetting.initial(),
  isExperimentalEnabled: false,
  isAIScribeAvailable: false,
  isAICapabilitySupported: isAICapabilitySupported,
  isLabelVisibility: false,
);

void main() {
  group('collapseThread is experimental and a child of thread', () {
    test('isExperimental is true', () {
      expect(PreferencesOptionType.collapseThread.isExperimental, isTrue);
    });

    test('parentType is thread', () {
      expect(
        PreferencesOptionType.collapseThread.parentType,
        PreferencesOptionType.thread,
      );
    });

    test('isChildOption is true', () {
      expect(PreferencesOptionType.collapseThread.isChildOption, isTrue);
    });
  });

  group('all other options: standard, no parent', () {
    for (final option in _standardTopLevelOptions) {
      test('${option.name}: not experimental, no parent, not child', () {
        expect(option.isExperimental, isFalse);
        expect(option.parentType, isNull);
        expect(option.isChildOption, isFalse);
      });
    }
  });

  group('PreferencesOptionType.isEnabled for collapseThread', () {
    for (final isEnabled in [true, false]) {
      test('returns $isEnabled when collapseThreadConfig.isEnabled is $isEnabled', () {
        final setting = PreferencesSetting([
          ThreadDetailConfig(isEnabled: true),
          CollapseThreadConfig(isEnabled: isEnabled),
        ]);
        expect(
          PreferencesOptionType.collapseThread.isEnabled(null, setting),
          isEnabled ? isTrue : isFalse,
        );
      });
    }
  });

  group('PreferencesOptionType.createToggledConfig', () {
    test('collapseThread toggles from false to true', () {
      final settings = PreferencesSetting([CollapseThreadConfig(isEnabled: false)]);
      final result =
          PreferencesOptionType.collapseThread.createToggledConfig(settings, false);
      expect((result as CollapseThreadConfig).isEnabled, isTrue);
    });

    test('thread toggles from true to false', () {
      final settings = PreferencesSetting([ThreadDetailConfig(isEnabled: true)]);
      final result =
          PreferencesOptionType.thread.createToggledConfig(settings, true);
      expect((result as ThreadDetailConfig).isEnabled, isFalse);
    });

    test('returns null for non-local options', () {
      final settings = PreferencesSetting.initial();
      expect(
        PreferencesOptionType.readReceipt.createToggledConfig(settings, true),
        isNull,
      );
      expect(
        PreferencesOptionType.aiNeedsAction.createToggledConfig(settings, false),
        isNull,
      );
    });
  });

  group('PreferencesOptionType.isVisible', () {
    test('readReceipt visible only when settingOption is present', () {
      expect(PreferencesOptionType.readReceipt.isVisible(_ctx()), isFalse);
      expect(PreferencesOptionType.readReceipt.isVisible(_serverCtx()), isTrue);
    });

    test('thread visible only when local configs are loaded', () {
      expect(
        PreferencesOptionType.thread.isVisible(_ctx(localSettings: PreferencesSetting([]))),
        isFalse,
      );
      expect(PreferencesOptionType.thread.isVisible(_ctx()), isTrue);
    });

    test('collapseThread hidden when experimental mode is off', () {
      expect(PreferencesOptionType.collapseThread.isVisible(_ctx()), isFalse);
    });

    test('collapseThread hidden when thread is disabled even if experimental on', () {
      final settings = PreferencesSetting([ThreadDetailConfig(isEnabled: false)]);
      expect(
        PreferencesOptionType.collapseThread.isVisible(
          _ctx(isExperimentalEnabled: true, localSettings: settings),
        ),
        isFalse,
      );
    });

    test('collapseThread visible when experimental on and thread enabled', () {
      final settings = PreferencesSetting([ThreadDetailConfig(isEnabled: true)]);
      expect(
        PreferencesOptionType.collapseThread.isVisible(
          _ctx(isExperimentalEnabled: true, localSettings: settings),
        ),
        isTrue,
      );
    });

    test('aiScribe hidden when capability not available', () {
      expect(PreferencesOptionType.aiScribe.isVisible(_ctx()), isFalse);
      expect(
        PreferencesOptionType.aiScribe.isVisible(_ctx(isAIScribeAvailable: true)),
        isTrue,
      );
    });

    test('aiNeedsAction requires server settings and AI capability', () {
      expect(PreferencesOptionType.aiNeedsAction.isVisible(_ctx()), isFalse);
      expect(
        PreferencesOptionType.aiNeedsAction.isVisible(_serverCtx()),
        isFalse,
      );
      expect(
        PreferencesOptionType.aiNeedsAction.isVisible(
          _serverCtx(isAICapabilitySupported: true),
        ),
        isTrue,
      );
    });

    test('label visible only when label visibility is enabled', () {
      expect(PreferencesOptionType.label.isVisible(_ctx()), isFalse);
      expect(PreferencesOptionType.label.isVisible(_ctx(isLabelVisibility: true)), isTrue);
    });
  });
}
