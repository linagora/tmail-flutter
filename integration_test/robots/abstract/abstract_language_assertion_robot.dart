import 'package:flutter/widgets.dart';

abstract class AbstractLanguageAssertionRobot {
  Future<void> expectLanguagesListed(List<Locale> locales);
  Future<void> expectLanguagesNotListed(List<Locale> locales);
  Future<void> expectLanguageSelected(Locale locale);
}
