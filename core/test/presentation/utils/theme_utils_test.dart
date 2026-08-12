import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/style/linagora_text_theme.dart';

void main() {
  group('ThemeUtils.buildAppTheme', () {
    testWidgets(
      'inherits every text theme slot from the design system',
      _inheritsEveryTextThemeSlot,
    );
    testWidgets(
      'registers the design system typography extension',
      _registersTypographyExtension,
    );
    testWidgets(
      'legacy text style helpers follow the design system font',
      _legacyHelpersFollowDesignSystemFont,
    );
  });

  group('ThemeUtils.withFallbackForTesting', () {
    testWidgets(
      'rebuilding a style only replaces its font family fallback',
      _rebuildingAStyleOnlyReplacesItsFallback,
    );
  });
}

Future<void> _inheritsEveryTextThemeSlot(WidgetTester tester) =>
    _onDesktop(() async {
      final theme = await _buildTheme(tester);
      final designSystem = LinagoraTextTheme.material();
      final slots = <String, List<TextStyle?>>{
        'displayLarge': [theme.textTheme.displayLarge, designSystem.displayLarge],
        'displayMedium': [theme.textTheme.displayMedium, designSystem.displayMedium],
        'displaySmall': [theme.textTheme.displaySmall, designSystem.displaySmall],
        'headlineLarge': [theme.textTheme.headlineLarge, designSystem.headlineLarge],
        'headlineMedium': [theme.textTheme.headlineMedium, designSystem.headlineMedium],
        'headlineSmall': [theme.textTheme.headlineSmall, designSystem.headlineSmall],
        'titleLarge': [theme.textTheme.titleLarge, designSystem.titleLarge],
        'titleMedium': [theme.textTheme.titleMedium, designSystem.titleMedium],
        'titleSmall': [theme.textTheme.titleSmall, designSystem.titleSmall],
        'labelLarge': [theme.textTheme.labelLarge, designSystem.labelLarge],
        'labelMedium': [theme.textTheme.labelMedium, designSystem.labelMedium],
        'labelSmall': [theme.textTheme.labelSmall, designSystem.labelSmall],
        'bodyLarge': [theme.textTheme.bodyLarge, designSystem.bodyLarge],
        'bodyMedium': [theme.textTheme.bodyMedium, designSystem.bodyMedium],
        'bodySmall': [theme.textTheme.bodySmall, designSystem.bodySmall],
      };

      slots.forEach((slot, styles) {
        _expectSameMetrics(slot, styles.first, styles.last);
        _expectUsableFallback(slot, styles.first);
      });
    });

Future<void> _registersTypographyExtension(WidgetTester tester) =>
    _onDesktop(() async {
      final theme = await _buildTheme(tester);
      final extension = theme.extension<LinagoraTextThemeExtension>();
      expect(extension, isNotNull);

      final designSystem = LinagoraTextThemeExtension.material();
      final slots = <String, List<TextStyle>>{
        'titleSemibold': [extension!.titleSemibold, designSystem.titleSemibold],
        'titleSmall2': [extension.titleSmall2, designSystem.titleSmall2],
        'bodyLargeBold': [extension.bodyLargeBold, designSystem.bodyLargeBold],
        'bodyLarge1': [extension.bodyLarge1, designSystem.bodyLarge1],
        'bodyLarge2': [extension.bodyLarge2, designSystem.bodyLarge2],
        'bodyMedium1': [extension.bodyMedium1, designSystem.bodyMedium1],
        'bodyMedium2': [extension.bodyMedium2, designSystem.bodyMedium2],
        'bodyMedium3': [extension.bodyMedium3, designSystem.bodyMedium3],
        'bodyMedium4': [extension.bodyMedium4, designSystem.bodyMedium4],
      };

      slots.forEach((slot, styles) {
        _expectSameMetrics(slot, styles.first, styles.last);
        _expectUsableFallback(slot, styles.first);
      });
    });

Future<void> _legacyHelpersFollowDesignSystemFont(WidgetTester tester) =>
    _onDesktop(() async {
      await _buildTheme(tester);
      final designSystemFont = LinagoraTextTheme.material().bodyMedium?.fontFamily;

      expect(designSystemFont, isNotNull);
      expect(ThemeUtils.defaultTextStyleInterFont.fontFamily, designSystemFont);
      expect(ThemeUtils.textStyleBodyBody1().fontFamily, designSystemFont);
      expect(ThemeUtils.textStyleInter400.fontFamily, designSystemFont);
      _expectUsableFallback(
        'defaultTextStyleInterFont',
        ThemeUtils.defaultTextStyleInterFont,
      );
    });

// Every const-constructible TextStyle field populated (Paint/List-typed
// fields — foreground, background, shadows, fontFeatures, fontVariations —
// are left at their defaults since they can't appear in a const literal),
// so a future SDK field that _withFallbackRequired forgets to copy shows up
// as a mismatch here instead of silently vanishing from every
// design-system-derived style.
Future<void> _rebuildingAStyleOnlyReplacesItsFallback(WidgetTester tester) =>
    _onDesktop(() async {
      const original = TextStyle(
        inherit: false,
        fontFamily: 'SomeFont',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        letterSpacing: 1,
        wordSpacing: 2,
        textBaseline: TextBaseline.alphabetic,
        height: 1.5,
        leadingDistribution: TextLeadingDistribution.even,
        locale: Locale('en', 'US'),
        color: Colors.red,
        backgroundColor: Colors.blue,
        decoration: TextDecoration.underline,
        decorationColor: Colors.green,
        decorationStyle: TextDecorationStyle.dashed,
        decorationThickness: 2,
        overflow: TextOverflow.ellipsis,
      );

      expect(
        ThemeUtils.withFallbackForTesting(original),
        original.copyWith(fontFamilyFallback: ConstantsUI.fontFamilyFallback),
      );
    });

// ConstantsUI.fontFamilyFallback is null on mobile and the test binding
// reports Android, so the fallback chain would never be exercised. The
// override has to be undone inside the test body, otherwise the widget
// tester fails the run for leaving a foundation debug variable set.
Future<void> _onDesktop(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<ThemeData> _buildTheme(WidgetTester tester) async {
  late ThemeData theme;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          theme = ThemeUtils.buildAppTheme(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return theme;
}

void _expectSameMetrics(String slot, TextStyle? actual, TextStyle? expected) {
  expect(actual, isNotNull, reason: '$slot is missing from the app theme');
  expect(expected, isNotNull, reason: '$slot is missing from the design system');
  expect(actual!.fontFamily, expected!.fontFamily, reason: '$slot fontFamily');
  expect(actual.fontSize, expected.fontSize, reason: '$slot fontSize');
  expect(actual.fontWeight, expected.fontWeight, reason: '$slot fontWeight');
  expect(actual.height, expected.height, reason: '$slot height');
  expect(actual.letterSpacing, expected.letterSpacing, reason: '$slot letterSpacing');
}

void _expectUsableFallback(String slot, TextStyle? style) {
  expect(style?.fontFamilyFallback, ConstantsUI.webFontFamilyFallback,
      reason: '$slot lost the fallback chain');
  // A design system style keeps its `package`, which would rewrite every
  // fallback entry to `packages/linagora_design_flutter/<family>` — families
  // the design system does not ship, silently killing the chain.
  expect(
    style?.fontFamilyFallback?.where((family) => family.startsWith('packages/')),
    isEmpty,
    reason: '$slot fallback was rewritten with a package prefix',
  );
}
