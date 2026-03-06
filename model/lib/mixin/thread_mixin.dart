import 'package:jmap_dart_client/jmap/mail/email/email.dart';

mixin ThreadMixin {
  List<EmailId>? emailIdsInThread;

  int get countEmailIdsInThread =>
      emailIdsInThread != null ? emailIdsInThread!.length : 0;
}
