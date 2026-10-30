import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  const mongolian = Locale('mn', 'MN');
  const english = Locale('en', 'US');

  void allowLanguages(String value) =>
      dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': value});

  setUp(() {
    PlatformInfo.isTestingForWeb = true;
    dotenv.testLoad();
  });

  tearDown(() => PlatformInfo.isTestingForWeb = false);

  group('LocalizationService on mobile test:', () {
    setUp(() => PlatformInfo.isTestingForWeb = false);

    test('should ignore ALLOWED_LANGUAGES and return every supported locale', () {
      allowLanguages('mn,vi');

      expect(
        LocalizationService.availableLocales,
        LocalizationService.supportedLocales,
      );
      expect(LocalizationService.availableDefaultLocale, english);
    });
  });

  group('LocalizationService.availableLocales test:', () {
    test('should return every supported locale when the option is not set', () {
      expect(
        LocalizationService.availableLocales,
        LocalizationService.supportedLocales,
      );
    });

    for (final value in ['', '  ', ' , ,']) {
      test('should return every supported locale when the option is "$value"', () {
        allowLanguages(value);

        expect(
          LocalizationService.availableLocales,
          LocalizationService.supportedLocales,
        );
      });
    }

    test('should keep the allowed locales in the configured order', () {
      allowLanguages('mn,en');

      expect(LocalizationService.availableLocales, [mongolian, english]);
    });

    test('should accept a quoted value', () {
      dotenv.testLoad(fileInput: 'ALLOWED_LANGUAGES="mn,en"');

      expect(LocalizationService.availableLocales, [mongolian, english]);
    });

    test('should trim codes and ignore their case', () {
      allowLanguages(' MN , En ');

      expect(LocalizationService.availableLocales, [mongolian, english]);
    });

    test('should drop duplicated codes', () {
      allowLanguages('mn,mn,en');

      expect(LocalizationService.availableLocales, [mongolian, english]);
    });

    test('should ignore unknown codes', () {
      allowLanguages('mn,xx');

      expect(LocalizationService.availableLocales, [mongolian]);
    });

    test('should return every supported locale when every code is unknown', () {
      allowLanguages('xx,yy');

      expect(
        LocalizationService.availableLocales,
        LocalizationService.supportedLocales,
      );
    });

    // Portuguese is not in the v0.35 catalog; region tags strip to `pt` and
    // are ignored like any other unknown code.
    for (final value in ['pt', 'pt-BR', 'pt_BR']) {
      test('should ignore unsupported "$value"', () {
        allowLanguages(value);

        expect(
          LocalizationService.availableLocales,
          LocalizationService.supportedLocales,
        );
      });
    }
  });

  group('LocalizationService.availableDefaultLocale test:', () {
    test('should be English when the option is not set', () {
      expect(LocalizationService.availableDefaultLocale, english);
    });

    test('should be English when English is allowed', () {
      allowLanguages('mn,en');

      expect(LocalizationService.availableDefaultLocale, english);
    });

    test('should be the first allowed locale when English is not allowed', () {
      allowLanguages('mn,fr');

      expect(LocalizationService.availableDefaultLocale, mongolian);
    });
  });

  test('supportedLocalesToLanguageTags should keep the full catalog', () {
    allowLanguages('mn,en');

    expect(
      LocalizationService.supportedLocalesToLanguageTags(),
      LocalizationService.supportedLocales
          .map((locale) => locale.toLanguageTag())
          .join(', '),
    );
  });
}
