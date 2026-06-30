import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

/// Mutable per-execution scratch space a strategy fills in: `position` here, date
/// cursors on the [filter] copy. The only place cursors may live, so they never
/// leak into the committed SSOT. See ADR-0093.
class SearchRequestSpec {
  const SearchRequestSpec({required this.filter, this.position, this.limit});

  /// Throwaway copy of the committed filter; cursors may be set here.
  final SearchEmailFilter filter;
  final int? position;
  final UnsignedInt? limit;

  /// `null` keeps `position`, `Some` sets it, `None` clears it (a distinction
  /// `int?` alone can't express).
  SearchRequestSpec copyWith({
    SearchEmailFilter? filter,
    Option<int>? positionOption,
    UnsignedInt? limit,
  }) {
    return SearchRequestSpec(
      filter: filter ?? this.filter,
      position: positionOption != null ? positionOption.toNullable() : position,
      limit: limit ?? this.limit,
    );
  }

  /// Starting spec before any strategy runs: filter = committed, default limit.
  factory SearchRequestSpec.base(SearchExecutionContext ctx) =>
      SearchRequestSpec(filter: ctx.committed, limit: ThreadConstants.defaultLimit);
}
