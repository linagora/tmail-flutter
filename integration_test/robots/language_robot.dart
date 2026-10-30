import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class LanguageRobot extends CoreRobot {
  LanguageRobot(super.$);

  Future<void> openLanguageContextMenu() async {
    await $(const ValueKey(UiKeys.languageDropDownButton)).tap();
  }

  Future<void> selectLanguage(
    Locale locale,
    AppLocalizations appLocalizations,
  ) async {
    await $(find.text(
            '${locale.getLanguageNameByCurrentLocale(appLocalizations)} - ${locale.getSourceLanguageName()}'))
        .tap();
  }
}
