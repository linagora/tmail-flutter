import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../abstract/abstract_language_robot.dart';
import '../language_robot.dart';

class MobileLanguageRobot extends LanguageRobot
    implements AbstractLanguageRobot {
  MobileLanguageRobot(super.$);

  @override
  Future<void> openLanguagePicker() async {
    await openLanguageContextMenu();
    await $.pumpAndSettle();
  }

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

  String _languageItemText(Locale locale) {
    final appLocalizations = AppLocalizations();
    return '${locale.getLanguageNameByCurrentLocale(appLocalizations)} - '
        '${locale.getSourceLanguageName()}';
  }
}
