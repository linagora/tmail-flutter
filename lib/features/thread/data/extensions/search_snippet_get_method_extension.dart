import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_method.dart';

extension SearchSnippetGetMethodExtension on SearchSnippetGetMethod {
  void addFiltersIfNotNull(Filter? filter) {
    if (filter != null) addFilters(filter);
  }
}
