import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';

/// Raw inputs of one search execution, bundled so each executor method takes a
/// single argument. The pagination context is derived from this during resolution.
class SearchExecutionRequest {
  const SearchExecutionRequest({
    required this.intent,
    required this.session,
    required this.accountId,
    required this.properties,
    required this.collapseThreads,
    required this.trashSpamMailboxIds,
  });

  final SearchExecutionIntent intent;
  final Session session;
  final AccountId accountId;
  final Properties properties;
  final bool collapseThreads;
  final Set<MailboxId>? trashSpamMailboxIds;
}
