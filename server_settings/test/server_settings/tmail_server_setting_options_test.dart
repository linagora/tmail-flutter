import 'package:flutter_test/flutter_test.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';

void main() {
  group('TMailServerSettingOptions', () {
    group('fromJson', () {
      test('parses ai.label-categorization.enabled as true', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.label-categorization.enabled': 'true',
        });
        expect(options.aiNeedsActionEnabled, isTrue);
      });

      test('parses ai.label-categorization.enabled as false', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.label-categorization.enabled': 'false',
        });
        expect(options.aiNeedsActionEnabled, isFalse);
      });

      test('leaves aiNeedsActionEnabled null when key is absent', () {
        final options = TMailServerSettingOptions.fromJson({});
        expect(options.aiNeedsActionEnabled, isNull);
      });

      test('does not read from legacy ai.needs-action.enabled key', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.needs-action.enabled': 'true',
        });
        expect(options.aiNeedsActionEnabled, isNull);
      });
    });

    group('toJson', () {
      test('serializes ai.label-categorization.enabled when set to true', () {
        final options = TMailServerSettingOptions(aiNeedsActionEnabled: true);
        final json = options.toJson();
        expect(json['ai.label-categorization.enabled'], isNotNull);
      });

      test('omits ai.label-categorization.enabled when null', () {
        final options = TMailServerSettingOptions();
        final json = options.toJson();
        expect(json.containsKey('ai.label-categorization.enabled'), isFalse);
      });

      test('does not include ai.needs-action.enabled key', () {
        final options = TMailServerSettingOptions(aiNeedsActionEnabled: true);
        final json = options.toJson();
        expect(json.containsKey('ai.needs-action.enabled'), isFalse);
      });
    });

    group('copyWith', () {
      test('overrides aiNeedsActionEnabled', () {
        final original = TMailServerSettingOptions(aiNeedsActionEnabled: false);
        final copy = original.copyWith(aiNeedsActionEnabled: true);
        expect(copy.aiNeedsActionEnabled, isTrue);
      });

      test('preserves aiNeedsActionEnabled when not supplied', () {
        final original = TMailServerSettingOptions(aiNeedsActionEnabled: true);
        final copy = original.copyWith(alwaysReadReceipts: false);
        expect(copy.aiNeedsActionEnabled, isTrue);
      });
    });
  });

  group('TmailServerSettingsExtension', () {
    test('isAINeedsActionEnabled returns true when field is true', () {
      final options = TMailServerSettingOptions(aiNeedsActionEnabled: true);
      expect(options.isAINeedsActionEnabled, isTrue);
    });

    test('isAINeedsActionEnabled returns false when field is false', () {
      final options = TMailServerSettingOptions(aiNeedsActionEnabled: false);
      expect(options.isAINeedsActionEnabled, isFalse);
    });

    test('isAINeedsActionEnabled defaults to false when field is null', () {
      final options = TMailServerSettingOptions();
      expect(options.isAINeedsActionEnabled, isFalse);
    });
  });
}
