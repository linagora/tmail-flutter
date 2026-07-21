import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

/// Per-call executor arguments, bundled so a dispatch stays a two-argument call.
class SearchDispatchContext {
  final Session session;
  final AccountId accountId;
  final Properties properties;
  final bool collapseThreads;
  final Set<MailboxId>? trashSpamMailboxIds;

  const SearchDispatchContext({
    required this.session,
    required this.accountId,
    required this.properties,
    required this.collapseThreads,
    required this.trashSpamMailboxIds,
  });
}
