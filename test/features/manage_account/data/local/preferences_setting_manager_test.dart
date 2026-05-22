import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

const _threadKey = 'PREFERENCES_SETTING_THREAD';
const _collapseThreadKey = 'PREFERENCES_SETTING_COLLAPSE_THREAD';
const _spamReportKey = 'PREFERENCES_SETTING_SPAM_REPORT';

PreferencesSettingManager _makeManager(SharedPreferences prefs) =>
    PreferencesSettingManager(prefs);

void main() {
  group('PreferencesSettingManager', () {
    late SharedPreferences prefs;
    late PreferencesSettingManager manager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      manager = _makeManager(prefs);
    });

    group('loadPreferences', () {
      test('returns initial when no keys present', () async {
        final setting = await manager.loadPreferences();
        expect(setting.threadConfig, isA<ThreadDetailConfig>());
        expect(setting.threadConfig.isEnabled, isFalse);
      });

      test('parses ThreadDetailConfig from stored key', () async {
        await prefs.setString(
          _threadKey,
          jsonEncode(ThreadDetailConfig(isEnabled: true).toJson()),
        );
        final setting = await manager.loadPreferences();
        expect(setting.threadConfig.isEnabled, isTrue);
      });

      test('parses CollapseThreadConfig from stored key', () async {
        await prefs.setString(
          _collapseThreadKey,
          jsonEncode(CollapseThreadConfig(isEnabled: true).toJson()),
        );
        final setting = await manager.loadPreferences();
        expect(setting.collapseThreadConfig.isEnabled, isTrue);
      });

      test('ignores unknown PREFERENCES_SETTING_* keys gracefully', () async {
        await prefs.setString('PREFERENCES_SETTING_UNKNOWN', '{"x":1}');
        final setting = await manager.loadPreferences();
        expect(setting.configs.isEmpty, isFalse);
      });
    });

    group('savePreferences', () {
      test('writes CollapseThreadConfig to correct key', () async {
        await manager.savePreferences(CollapseThreadConfig(isEnabled: true));
        expect(prefs.containsKey(_collapseThreadKey), isTrue);
        final stored = CollapseThreadConfig.fromJson(
          jsonDecode(prefs.getString(_collapseThreadKey)!) as Map<String, dynamic>,
        );
        expect(stored.isEnabled, isTrue);
      });

      test('SpamReportConfig goes through read-merge-write path', () async {
        await prefs.setString(
          _spamReportKey,
          jsonEncode(SpamReportConfig(
            isEnabled: true,
            lastTimeDismissedMilliseconds: 9999,
          ).toJson()),
        );

        await manager.savePreferences(SpamReportConfig(isEnabled: false));

        final stored = SpamReportConfig.fromJson(
          jsonDecode(prefs.getString(_spamReportKey)!) as Map<String, dynamic>,
        );
        expect(stored.isEnabled, isFalse);
        expect(stored.lastTimeDismissedMilliseconds, 9999);
      });
    });

    group('updateTextFormattingMenu', () {
      test('writes isDisplayed=true and round-trips', () async {
        await manager.updateTextFormattingMenu(isDisplayed: true);
        final config = await manager.getTextFormattingMenuConfig();
        expect(config.isDisplayed, isTrue);
      });
    });

    group('_readConfig (via getThreadConfig)', () {
      test('returns defaultFactory when key absent', () async {
        final config = await manager.getThreadConfig();
        expect(config, equals(ThreadDetailConfig.initial()));
      });

      test('returns stored value when key present', () async {
        await prefs.setString(
          _threadKey,
          jsonEncode(ThreadDetailConfig(isEnabled: true).toJson()),
        );
        final config = await manager.getThreadConfig();
        expect(config.isEnabled, isTrue);
      });
    });

    group('experimental mode', () {
      test('getExperimentalModeEnabled returns false when not set', () async {
        expect(await manager.getExperimentalModeEnabled(), isFalse);
      });

      test('enableExperimentalMode persists true', () async {
        await manager.enableExperimentalMode();
        expect(await manager.getExperimentalModeEnabled(), isTrue);
      });

      test('getExperimentalModeEnabled reads from SharedPreferences directly', () async {
        await prefs.setBool('EXPERIMENTAL_MODE_ENABLED', true);
        expect(await manager.getExperimentalModeEnabled(), isTrue);
      });
    });
  });
}
