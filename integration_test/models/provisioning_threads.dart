import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

typedef CreatedThreads = ({Map<int, List<EmailId>> emailIds, State? state});

class ProvisioningThreads {
  final String subjectPrefix;
  final List<int> threadNumbers;
  final int repliesPerThread;
  final DateTime newest;
  final bool seen;
  final bool starred;

  const ProvisioningThreads({
    required this.subjectPrefix,
    required this.threadNumbers,
    required this.repliesPerThread,
    required this.newest,
    this.seen = true,
    this.starred = false,
  });
}
