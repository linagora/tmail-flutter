import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_language_assertion_robot.dart';

class MobileLanguageAssertionRobot extends CoreRobot
    implements AbstractLanguageAssertionRobot {
  MobileLanguageAssertionRobot(super.$);

  @override
  Future<void> expectLanguagesListed(List<Locale> locales) async {
    for (final locale in locales) {
      // exists, not visible: the mobile bottom sheet scrolls on small screens
      expect(
        $(_languageItemText(locale)).exists,
        isTrue,
        reason: '${locale.toLanguageTag()} should be listed',
      );
    }
  }

  @override
  Future<void> expectLanguagesNotListed(List<Locale> locales) async {
    for (final locale in locales) {
      expect(find.text(_languageItemText(locale)), findsNothing);
    }
  }

  @override
  Future<void> expectLanguageSelected(Locale locale) async {
    final languageName = locale.getLanguageNameByCurrentLocale(AppLocalizations());
    await $(const ValueKey(UiKeys.languageDropDownButton))
        .$(languageName)
        .waitUntilVisible();
  }

  String _languageItemText(Locale locale) {
    final appLocalizations = AppLocalizations();
    return '${locale.getLanguageNameByCurrentLocale(appLocalizations)} - '
        '${locale.getSourceLanguageName()}';
  }
}
