import 'package:jmap_dart_client/jmap/mail/email/email.dart';

extension EmailIdExtension on EmailId {
  String get asString => id.value;
}