import 'package:core/utils/platform_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

// Own file: dotenv is a global that cannot be unloaded once a test loads it.
void main() {
  test(
    'availableLocales should return every supported locale '
    'when dotenv is not loaded',
  () {
    PlatformInfo.isTestingForWeb = true;
    addTearDown(() => PlatformInfo.isTestingForWeb = false);

    expect(dotenv.isInitialized, isFalse);
    expect(
      LocalizationService.availableLocales,
      LocalizationService.supportedLocales,
    );
    expect(
      LocalizationService.availableDefaultLocale,
      LocalizationService.defaultLocale,
    );
  });
}
