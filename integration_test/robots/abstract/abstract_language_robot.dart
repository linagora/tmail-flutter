import 'package:flutter/widgets.dart';

abstract class AbstractLanguageRobot {
  Future<void> openLanguagePicker();
  Future<void> expectLanguagesListed(List<Locale> locales);
  Future<void> expectLanguagesNotListed(List<Locale> locales);
}
