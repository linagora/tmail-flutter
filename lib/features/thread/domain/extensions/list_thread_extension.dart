import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/thread/thread.dart';

extension ThreadListExtension on List<Thread>? {
  Map<ThreadId, List<EmailId>> toThreadEmailIdsMap() {
    final threads = this;
    if (threads == null || threads.isEmpty) return const {};
    return {for (final thread in threads) thread.id: thread.emailIds};
  }
}
