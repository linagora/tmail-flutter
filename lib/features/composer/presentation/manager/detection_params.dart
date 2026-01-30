import 'package:tmail_ui_user/features/composer/presentation/manager/keyword_filter.dart';

///  Simple DTO to pass parameters to the Isolate.
/// Isolates cannot share memory, so we package everything here.
class DetectionParams {
  final String text;
  final List<String> includeList; // Keywords to ADD to the search.
  final List<KeywordFilter> filters; // Filters to BLOCK specific matches.

  DetectionParams({
    required this.text,
    required this.includeList,
    required this.filters,
  });
}