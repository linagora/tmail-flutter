import 'package:jmap_dart_client/jmap/mail/email/email.dart';

abstract class LocalStorageBrowserDatasource {
  Future<void> storeComposedEmail(Email email);

  Future<Email> getComposedEmail();

  Future<void> deleteComposedEmail();
}