import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';

/// Naming convention:
/// - `IfNotNull`  — applies the method only when the value is non-null.
/// - `IfAvailable` — applies the method when the value meets an additional
///   semantic condition beyond null (e.g. position > 0, collapseThreads == true).
extension QueryEmailMethodExtension on QueryEmailMethod {
  void addLimitIfNotNull(UnsignedInt? limit) {
    if (limit != null) addLimit(limit);
  }

  /// Only sets position when it is positive; position 0 is the default start
  /// and does not need to be sent explicitly.
  void addPositionIfAvailable(int? position) {
    if (position != null && position > 0) addPosition(position);
  }

  void addSortsIfNotNull(Set<Comparator>? sort) {
    if (sort != null) addSorts(sort);
  }

  void addFiltersIfNotNull(Filter? filter) {
    if (filter != null) addFilters(filter);
  }

  /// Only enables collapse-threads when the flag is explicitly `true`;
  /// null or false means the feature is not requested.
  void addCollapseThreadsIfAvailable(bool? collapseThreads) {
    if (collapseThreads == true) {
      addCollapseThreads(true);
    }
  }
}
