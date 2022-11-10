import 'dart:ui';

abstract class ManageAccountDataSource {
  Future<void> persistLanguage(Locale localeCurrent);
}