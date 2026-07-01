import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

/// Resolved arguments for one search-interactor call — one object for the three
/// interactors (search / search-more / refresh-changes). Cursors are already resolved
/// by the strategy; this only carries values. See ADR-0093.
class SearchEmailQueryParams {
  const SearchEmailQueryParams({
    required this.session,
    required this.accountId,
    required this.filter,
    required this.sort,
    required this.properties,
    required this.collapseThreads,
    this.limit,
    this.position,
    this.lastEmailId,
    this.needRefreshSearchState = false,
  });

  final Session session;
  final AccountId accountId;
  final Filter? filter;
  final Set<Comparator>? sort;
  final Properties? properties;
  final bool collapseThreads;
  final UnsignedInt? limit;
  final int? position;

  /// Load-more only — excludes the cursor row from the appended page.
  final EmailId? lastEmailId;
  final bool needRefreshSearchState;
}
