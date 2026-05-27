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

      test('parses legacy ai.needs-action.enabled as true', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.needs-action.enabled': 'true',
        });
        expect(options.aiNeedsActionEnabled, isTrue);
      });

      test('parses legacy ai.needs-action.enabled as false', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.needs-action.enabled': 'false',
        });
        expect(options.aiNeedsActionEnabled, isFalse);
      });

      test('parses both keys independently when both present', () {
        final options = TMailServerSettingOptions.fromJson({
          'ai.needs-action.enabled': 'false',
          'ai.label-categorization.enabled': 'true',
        });
        expect(options.aiNeedsActionEnabled, isFalse);
        expect(options.aiLabelCategorizationEnabled, isTrue);
      });

      test('leaves both fields null when neither key present', () {
        final options = TMailServerSettingOptions.fromJson({});
        expect(options.aiNeedsActionEnabled, isNull);
        expect(options.aiLabelCategorizationEnabled, isNull);
      });
    });

    group('toJson', () {
      test('serializes ai.label-categorization.enabled when set to true', () {
        final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final json = options.toJson();
        expect(json['ai.label-categorization.enabled'], isNotNull);
      });

      test('omits ai.label-categorization.enabled when null', () {
        final options = TMailServerSettingOptions();
        final json = options.toJson();
        expect(json.containsKey('ai.label-categorization.enabled'), isFalse);
      });

      test('never includes legacy ai.needs-action.enabled key', () {
        final options = TMailServerSettingOptions(aiNeedsActionEnabled: true);
        final json = options.toJson();
        expect(json.containsKey('ai.needs-action.enabled'), isFalse);
      });
    });

    group('copyWith', () {
      test('overrides aiLabelCategorizationEnabled', () {
        final original = TMailServerSettingOptions(aiLabelCategorizationEnabled: false);
        final copy = original.copyWith(aiLabelCategorizationEnabled: true);
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('preserves aiLabelCategorizationEnabled when not supplied', () {
        final original = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final copy = original.copyWith(alwaysReadReceipts: false);
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('carries through legacy aiNeedsActionEnabled unchanged', () {
        final original = TMailServerSettingOptions(aiNeedsActionEnabled: true);
        final copy = original.copyWith(alwaysReadReceipts: false);
        expect(copy.aiNeedsActionEnabled, isTrue);
      });
    });
  });

  group('TmailServerSettingsExtension', () {
    test('isAINeedsActionEnabled returns true from new key', () {
      final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
      expect(options.isAINeedsActionEnabled, isTrue);
    });

    test('isAINeedsActionEnabled returns false from new key', () {
      final options = TMailServerSettingOptions(aiLabelCategorizationEnabled: false);
      expect(options.isAINeedsActionEnabled, isFalse);
    });

    test('isAINeedsActionEnabled falls back to legacy key when new key absent', () {
      final options = TMailServerSettingOptions(aiNeedsActionEnabled: true);
      expect(options.isAINeedsActionEnabled, isTrue);
    });

    test('isAINeedsActionEnabled new key takes precedence over legacy key', () {
      final options = TMailServerSettingOptions(
        aiNeedsActionEnabled: false,
        aiLabelCategorizationEnabled: true,
      );
      expect(options.isAINeedsActionEnabled, isTrue);
    });

    test('isAINeedsActionEnabled defaults to false when both fields null', () {
      final options = TMailServerSettingOptions();
      expect(options.isAINeedsActionEnabled, isFalse);
    });
  });
}
