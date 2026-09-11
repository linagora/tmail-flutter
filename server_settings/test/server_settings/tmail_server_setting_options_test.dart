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

    group('sentry.user-opt-in', () {
      test('parses sentry.user-opt-in as true', () {
        final options = TMailServerSettingOptions.fromJson({
          'sentry.user-opt-in': 'true',
        });
        expect(options.sentryUserOptIn, isTrue);
      });

      test('parses sentry.user-opt-in as false', () {
        final options = TMailServerSettingOptions.fromJson({
          'sentry.user-opt-in': 'false',
        });
        expect(options.sentryUserOptIn, isFalse);
      });

      test('leaves sentryUserOptIn null when key absent, so the instance default applies', () {
        expect(TMailServerSettingOptions.fromJson({}).sentryUserOptIn, isNull);
      });

      test('serializes sentry.user-opt-in when opting in', () {
        final json = TMailServerSettingOptions(sentryUserOptIn: true).toJson();
        expect(json['sentry.user-opt-in'], 'true');
      });

      test('serializes sentry.user-opt-in when opting out', () {
        final json = TMailServerSettingOptions(sentryUserOptIn: false).toJson();
        expect(json['sentry.user-opt-in'], 'false');
      });

      test('omits sentry.user-opt-in while the user has not chosen', () {
        final json = TMailServerSettingOptions().toJson();
        expect(json.containsKey('sentry.user-opt-in'), isFalse);
      });

      test('withSentryUserOptIn overrides sentryUserOptIn', () {
        final options = TMailServerSettingOptions(sentryUserOptIn: true)
            .withSentryUserOptIn(false);
        expect(options.sentryUserOptIn, isFalse);
      });

      test('copyWith preserves sentryUserOptIn when another option changes', () {
        final options = TMailServerSettingOptions(sentryUserOptIn: true)
            .copyWith(alwaysReadReceipts: true);
        expect(options.sentryUserOptIn, isTrue);
      });
    });

    group('copyWith', () {
      test('keeps settings the patch does not mention', () {
        final updated = TMailServerSettingOptions(
          alwaysReadReceipts: true,
          language: 'fr',
          sentryUserOptIn: true,
        ).copyWith(displaySenderPriority: false);

        expect(updated.alwaysReadReceipts, isTrue);
        expect(updated.language, 'fr');
        expect(updated.sentryUserOptIn, isTrue);
        expect(updated.displaySenderPriority, isFalse);
      });

      test('keeps a setting that is set to false, which is a real choice', () {
        final updated = TMailServerSettingOptions(sentryUserOptIn: false)
            .copyWith(language: 'fr');

        expect(updated.sentryUserOptIn, isFalse);
      });

      test('applies a patch that sets a value to false', () {
        final updated = TMailServerSettingOptions(alwaysReadReceipts: true)
            .copyWith(alwaysReadReceipts: false);

        expect(updated.alwaysReadReceipts, isFalse);
      });

      test('leaves the receiver untouched', () {
        final original = TMailServerSettingOptions();

        final updated = original.withSentryUserOptIn(true);

        expect(original.sentryUserOptIn, isNull);
        expect(updated.sentryUserOptIn, isTrue);
      });

      test('an empty patch changes nothing', () {
        final original = TMailServerSettingOptions(
          alwaysReadReceipts: true,
          sentryUserOptIn: false,
        );

        expect(original.copyWith(), original);
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
        final copy = original.copyWith(
          aiLabelCategorizationEnabled: true,
        );
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('preserves aiLabelCategorizationEnabled when not supplied', () {
        final original = TMailServerSettingOptions(aiLabelCategorizationEnabled: true);
        final copy = original.copyWith(
          alwaysReadReceipts: false,
        );
        expect(copy.aiLabelCategorizationEnabled, isTrue);
      });

      test('preserves aiLabelCategorizationEnabled as null when not supplied', () {
        final original = TMailServerSettingOptions();
        final copy = original.copyWith(
          alwaysReadReceipts: false,
        );
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
