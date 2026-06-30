import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';

/// Read-only inputs a strategy reasons over. Strategies never mutate it — cursor
/// writes go to the transient `SearchRequestSpec`. See ADR-0093.
class SearchExecutionContext {
  const SearchExecutionContext({
    required this.intent,
    required this.committed,
    required this.collapseThreads,
  });

  final SearchExecutionIntent intent;

  /// Committed SSOT snapshot (never the draft) — what the result chips show.
  final SearchEmailFilter committed;

  /// Render mode, not user intent; when on, every sort pages by `position`
  /// (since #4651).
  final bool collapseThreads;
}
