import 'dart:ui';

abstract class ManageAccountRepository {
  Future<void> persistLanguage(Locale localeCurrent);
}