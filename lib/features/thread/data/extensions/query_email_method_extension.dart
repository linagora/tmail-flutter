import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';

extension QueryEmailMethodExtension on QueryEmailMethod {
  void addLimitIfNotNull(UnsignedInt? limit) {
    if (limit != null) addLimit(limit);
  }

  void addPositionIfValid(int? position) {
    if (position != null && position > 0) addPosition(position);
  }

  void addSortsIfNotNull(Set<Comparator>? sort) {
    if (sort != null) addSorts(sort);
  }

  void addFiltersIfNotNull(Filter? filter) {
    if (filter != null) addFilters(filter);
  }

  void addCollapseThreadsIfValid(bool? collapseThreads) {
    if (collapseThreads != null && collapseThreads) {
      addCollapseThreads(collapseThreads);
    }
  }
}
