import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

/// Wire identity of one search execution: two executions with equal keys send
/// the exact same `Email/query`, so the executor needs to run only one of them.
class SearchQueryKey with EquatableMixin {
  const SearchQueryKey({
    required this.intentType,
    required this.accountId,
    required this.filter,
    required this.trashSpamMailboxIds,
    required this.properties,
    required this.collapseThreads,
    this.limit,
    this.position,
    this.lastEmailId,
  });

  final Type intentType;
  final AccountId accountId;

  /// The resolved (cursor-bearing) filter the request is built from.
  final SearchEmailFilter filter;
  final Set<MailboxId>? trashSpamMailboxIds;
  final Set<String> properties;
  final bool collapseThreads;
  final num? limit;
  final int? position;
  final EmailId? lastEmailId;

  @override
  List<Object?> get props => [
        intentType,
        accountId,
        filter,
        trashSpamMailboxIds,
        properties,
        collapseThreads,
        limit,
        position,
        lastEmailId,
      ];
}
