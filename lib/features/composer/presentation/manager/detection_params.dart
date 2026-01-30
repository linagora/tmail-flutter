import 'package:tmail_ui_user/features/composer/presentation/manager/keyword_filter.dart';

/// Data Transfer Object used to package data sent to the Isolate.
/// Since Isolates cannot share memory, we need a simple object to pass parameters.
class DetectionParams {
  final String text;
  final List<KeywordFilter> filters;

  DetectionParams({required this.text, required this.filters});
}