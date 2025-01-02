import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

extension ListIdExtension on Iterable<Id> {
  Iterable<EmailId> toEmailIds() => map((id) => EmailId(id));
}