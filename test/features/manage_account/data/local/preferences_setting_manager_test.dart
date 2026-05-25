import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/default_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/empty_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late PreferencesSettingManager manager;

  const storagePrefix = 'PREFERENCES_SETTING';
  String storageKey(String suffix) => '${storagePrefix}_$suffix';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    manager = PreferencesSettingManager(sharedPreferences);
  });

  group('loadPreferences', () {
    test(
      'WHEN storage is empty\n'
      'THEN returns PreferencesSetting.initial()',
      () async {
        final result = await manager.loadPreferences();

        expect(result, PreferencesSetting.initial());
      },
    );

    test(
      'WHEN a known config is stored\n'
      'THEN that config is correctly parsed',
      () async {
        await sharedPreferences.setString(
          storageKey(ThreadDetailConfig.keySuffix),
          jsonEncode(ThreadDetailConfig(isEnabled: true).toJson()),
        );

        final result = await manager.loadPreferences();

        expect(result.threadConfig.isEnabled, isTrue);
      },
    );

    test(
      'WHEN all known configs are stored\n'
      'THEN each is correctly typed and returned',
      () async {
        await sharedPreferences.setString(
          storageKey(ThreadDetailConfig.keySuffix),
          jsonEncode(ThreadDetailConfig(isEnabled: true).toJson()),
        );
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig(isEnabled: false, lastTimeDismissedMilliseconds: 1000).toJson()),
        );
        await sharedPreferences.setString(
          storageKey(TextFormattingMenuConfig.keySuffix),
          jsonEncode(TextFormattingMenuConfig(isDisplayed: true).toJson()),
        );
        await sharedPreferences.setString(
          storageKey(AIScribeConfig.keySuffix),
          jsonEncode(AIScribeConfig(isEnabled: false).toJson()),
        );
        await sharedPreferences.setString(
          storageKey(LabelConfig.keySuffix),
          jsonEncode(LabelConfig(isEnabled: false).toJson()),
        );

        final result = await manager.loadPreferences();

        expect(result.threadConfig.isEnabled, isTrue);
        expect(result.spamReportConfig.isEnabled, isFalse);
        expect(result.spamReportConfig.lastTimeDismissedMilliseconds, 1000);
        expect(result.textFormattingMenuConfig.isDisplayed, isTrue);
        expect(result.aiScribeConfig.isEnabled, isFalse);
        expect(result.labelConfig.isEnabled, isFalse);
      },
    );

    test(
      'WHEN a prefixed key has no registered factory\n'
      'THEN a DefaultPreferencesConfig is included in the result',
      () async {
        await sharedPreferences.setString(
          storageKey('UNKNOWN_CONFIG'),
          jsonEncode({'foo': 'bar'}),
        );

        final result = await manager.loadPreferences();

        expect(result.configs.whereType<DefaultPreferencesConfig>(), isNotEmpty);
      },
    );

    test(
      'WHEN a prefixed key holds malformed JSON\n'
      'THEN an EmptyPreferencesConfig is included in the result',
      () async {
        await sharedPreferences.setString(
          storageKey(ThreadDetailConfig.keySuffix),
          'not-valid-json',
        );

        final result = await manager.loadPreferences();

        expect(result.configs.whereType<EmptyPreferencesConfig>(), isNotEmpty);
      },
    );

    test(
      'WHEN the same configs are stored in different key insertion orders\n'
      'THEN both loads produce equal PreferencesSetting (sorted order is stable)',
      () async {
        await sharedPreferences.setString(
          storageKey(ThreadDetailConfig.keySuffix),
          jsonEncode(ThreadDetailConfig().toJson()),
        );
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig().toJson()),
        );
        final firstLoadSetting = await manager.loadPreferences();

        SharedPreferences.setMockInitialValues({});
        sharedPreferences = await SharedPreferences.getInstance();
        manager = PreferencesSettingManager(sharedPreferences);

        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig().toJson()),
        );
        await sharedPreferences.setString(
          storageKey(ThreadDetailConfig.keySuffix),
          jsonEncode(ThreadDetailConfig().toJson()),
        );
        final secondLoadSetting = await manager.loadPreferences();

        expect(firstLoadSetting, equals(secondLoadSetting));
      },
    );
  });

  group('savePreferences', () {
    test(
      'WHEN saving a non-SpamReport config\n'
      'THEN it is written as JSON at the correct key',
      () async {
        await manager.savePreferences(ThreadDetailConfig(isEnabled: true));

        final storedJson = sharedPreferences.getString(storageKey(ThreadDetailConfig.keySuffix));
        expect(storedJson, isNotNull);
        final parsedConfig = ThreadDetailConfig.fromJson(jsonDecode(storedJson!) as Map<String, dynamic>);
        expect(parsedConfig.isEnabled, isTrue);
      },
    );

    test(
      'WHEN saving SpamReportConfig\n'
      'THEN existing lastTimeDismissedMilliseconds is preserved',
      () async {
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig(isEnabled: true, lastTimeDismissedMilliseconds: 9999).toJson()),
        );

        await manager.savePreferences(SpamReportConfig(isEnabled: false));

        final result = await manager.getSpamReportConfig();
        expect(result.isEnabled, isFalse);
        expect(result.lastTimeDismissedMilliseconds, 9999);
      },
    );
  });

  group('updateSpamReport', () {
    test(
      'WHEN updating isEnabled only\n'
      'THEN lastTimeDismissedMilliseconds is preserved',
      () async {
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig(isEnabled: true, lastTimeDismissedMilliseconds: 5000).toJson()),
        );

        await manager.updateSpamReport(isEnabled: false);

        final result = await manager.getSpamReportConfig();
        expect(result.isEnabled, isFalse);
        expect(result.lastTimeDismissedMilliseconds, 5000);
      },
    );

    test(
      'WHEN updating lastTimeDismissedMilliseconds only\n'
      'THEN isEnabled is preserved',
      () async {
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig(isEnabled: false, lastTimeDismissedMilliseconds: 0).toJson()),
        );

        await manager.updateSpamReport(lastTimeDismissedMilliseconds: 7777);

        final result = await manager.getSpamReportConfig();
        expect(result.isEnabled, isFalse);
        expect(result.lastTimeDismissedMilliseconds, 7777);
      },
    );

    test(
      'WHEN no existing config in storage\n'
      'THEN stores default values merged with the provided fields',
      () async {
        await manager.updateSpamReport(isEnabled: false, lastTimeDismissedMilliseconds: 1234);

        final result = await manager.getSpamReportConfig();
        expect(result.isEnabled, isFalse);
        expect(result.lastTimeDismissedMilliseconds, 1234);
      },
    );
  });

  group('getSpamReportConfig', () {
    test(
      'WHEN not stored\n'
      'THEN returns SpamReportConfig.initial()',
      () async {
        final result = await manager.getSpamReportConfig();

        expect(result, SpamReportConfig.initial());
      },
    );

    test(
      'WHEN stored\n'
      'THEN returns the parsed config',
      () async {
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          jsonEncode(SpamReportConfig(isEnabled: false, lastTimeDismissedMilliseconds: 42).toJson()),
        );

        final result = await manager.getSpamReportConfig();

        expect(result.isEnabled, isFalse);
        expect(result.lastTimeDismissedMilliseconds, 42);
      },
    );

    test(
      'WHEN stored value is malformed JSON\n'
      'THEN returns SpamReportConfig.initial()',
      () async {
        await sharedPreferences.setString(
          storageKey(SpamReportConfig.keySuffix),
          'not-valid-json',
        );

        final result = await manager.getSpamReportConfig();

        expect(result, SpamReportConfig.initial());
      },
    );
  });
}
