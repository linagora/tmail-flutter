import 'package:core/utils/web_uri_parser.dart';

const _eventsPathSegment = 'events';

extension CalendarUrlExtension on String? {
  Uri? resolveCalendarEventUrl(String? eventUid) {
    final normalizedUid = eventUid?.trim();
    if (normalizedUid == null || normalizedUid.isEmpty) return null;

    final baseUri = _parseCalendarBaseUri(this);
    if (baseUri == null) return null;

    final pathSegments = baseUri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (pathSegments.isEmpty || pathSegments.last != _eventsPathSegment) {
      pathSegments.add(_eventsPathSegment);
    }

    return Uri(
      scheme: baseUri.scheme.toLowerCase(),
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      pathSegments: [
        ...pathSegments,
        normalizedUid,
      ],
    );
  }
}

Uri? _parseCalendarBaseUri(String? calendarUrl) {
  final baseUrl = calendarUrl?.trim();
  if (baseUrl == null || baseUrl.isEmpty) return null;

  final baseUri = _tryParseCalendarBaseUri(baseUrl);
  if (baseUri != null) return baseUri;

  final decodedBaseUrl = _tryDecodeCalendarBaseUrl(baseUrl);
  if (decodedBaseUrl == null || decodedBaseUrl == baseUrl) return null;
  return _tryParseCalendarBaseUri(decodedBaseUrl);
}

Uri? _tryParseCalendarBaseUri(String baseUrl) {
  final baseUri = WebUriParser.tryParse(
    baseUrl,
    inferMissingScheme: true,
    allowHttpLocalhost: true,
  );
  return baseUri != null && !baseUri.hasQuery && !baseUri.hasFragment
      ? baseUri
      : null;
}

String? _tryDecodeCalendarBaseUrl(String baseUrl) {
  try {
    return Uri.decodeComponent(baseUrl);
  } on ArgumentError {
    return null;
  }
}
