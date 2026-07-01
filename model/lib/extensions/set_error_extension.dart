import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

/// Stable, minification-proof string helpers for JMAP [SetError].
///
/// [SetError] and [Id] don't override `toString()`, so in a release/web build
/// their default `toString()` emits the minified runtime type name
/// (e.g. `Instance of 'minified:eK'`). Interpolating them directly into
/// exception messages or logs produces unreadable output like
/// `{minified:b2: minified:eK}` in Sentry. These helpers format them from the
/// stable string fields (`type.value`, `description`, `Id.value`) instead.
extension SetErrorLogExtension on SetError {
  String get logMessage => '[${type.value}] ${description ?? ''}';
}

extension MapIdSetErrorLogExtension on Map<Id, SetError> {
  /// Formats the errors as `id: [type] description, ...` with no minified types.
  String toLogMessage() =>
      entries.map((e) => '${e.key.value}: ${e.value.logMessage}').join(', ');
}
