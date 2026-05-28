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
        expect(options.aiLabelCategorizationEnabled, isTrue);
      });

      test('parses ai.label-categorization.enabled as false', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.label-categorization.enabled': 'false',
        });
        expect(options.aiLabelCategorizationEnabled, isFalse);
      });

      test('leaves aiNeedsActionEnabled null when key absent', () {
        final options = TMailServerSettingOptions.fromJson({});
        expect(options.aiLabelCategorizationEnabled, isNull);
      });
    });

    group('toJson', () {
      test('serializes ai.label-categorization.enabled when set to true', () {
        final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final json = options.toJson();
        expect(json['ai.label-categorization.enabled'], isNotNull);
      });

      test('serializes ai.label-categorization.enabled when set to false', () {
        final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: false);
        final json = options.toJson();
        expect(json['ai.label-categorization.enabled'], isNotNull);
      });

      test('omits ai.label-categorization.enabled when null', () {
        final options = TMailServerSettingOptions();
        final json = options.toJson();
        expect(json.containsKey('ai.label-categorization.enabled'), isFalse);
      });

      test('does not include legacy ai.needs-action.enabled key', () {
        final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final json = options.toJson();
        expect(json.containsKey('ai.needs-action.enabled'), isFalse);
      });
    });

    group('copyWith', () {
      test('overrides aiLabelCategorizationEnabled', () {
        final original = TMailServerSettingOptions(aiLabelCategorizationEnabled: false);
        final copy = original.copyWith(aiNeedsActionEnabled: true);
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('preserves aiLabelCategorizationEnabled when not supplied', () {
        final original = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final copy = original.copyWith(alwaysReadReceipts: false);
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('preserves aiLabelCategorizationEnabled as null when not supplied', () {
        final original = TMailServerSettingOptions();
        final copy = original.copyWith(alwaysReadReceipts: false);
        expect(copy.aiLabelCategorizationEnabled, isNull);
      });
    });
  });

  group('TmailServerSettingsExtension', () {
    test('isAILabelCategorizationEnabled returns true when aiLabelCategorizationEnabled is true', () {
      final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
      expect(options.isAILabelCategorizationEnabled, isTrue);
    });

    test('isAILabelCategorizationEnabled returns false when aiLabelCategorizationEnabled is false', () {
      final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: false);
      expect(options.isAILabelCategorizationEnabled, isFalse);
    });

    test('isAILabelCategorizationEnabled defaults to false when aiLabelCategorizationEnabled is null', () {
      final options = TMailServerSettingOptions();
      expect(options.isAILabelCategorizationEnabled, isFalse);
    });
  });
}
