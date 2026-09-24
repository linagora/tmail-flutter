import 'package:core/utils/user_url_template.dart';
import 'package:core/utils/url_template.dart';
import 'package:core/utils/web_uri_parser.dart';

const _eventsPathSegment = 'events';
const _uidPlaceholderName = 'uid';
const _caseInsensitivePlaceholderNames = {
  _uidPlaceholderName,
  ...UserUrlTemplateVariables.names,
};

final class CalendarEventUrlRequest {
  final String? eventUid;
  final String? ownerEmail;
  final String? domainName;

  const CalendarEventUrlRequest({
    required this.eventUid,
    this.ownerEmail,
    this.domainName,
  });
}

class CalendarUrlTemplate {
  final String value;

  const CalendarUrlTemplate(this.value);

  String? resolveEventUrl(CalendarEventUrlRequest request) {
    final normalizedTemplate = value._trimmedNonEmpty;
    final validUid = request.eventUid._validEventUid;
    final normalizedDomainName = request.domainName._trimmedNonEmpty;
    if (normalizedTemplate == null || validUid == null) return null;
    if (request.domainName != null && normalizedDomainName == null) return null;

    final urlTemplate = UrlTemplate.withSelectedEncodedPlaceholders(
      normalizedTemplate,
      encodedPlaceholderNames: UserUrlTemplateVariables.names,
    );
    if (!urlTemplate.hasOnlySupportedPlaceholders(
      names: UserUrlTemplateVariables.names,
      caseInsensitiveNames: _caseInsensitivePlaceholderNames,
    )) {
      return null;
    }

    final hasUidPlaceholder = urlTemplate.usesPlaceholder(
      _uidPlaceholderName,
      caseSensitive: false,
    );
    final resolvedTemplate = UserUrlTemplate.fromUrlTemplate(urlTemplate).resolve(
      ownerEmail: request.ownerEmail,
      domainName: normalizedDomainName,
      variables: {
        _uidPlaceholderName: Uri.encodeComponent(validUid),
      },
      caseInsensitiveVariables: _caseInsensitivePlaceholderNames,
    );
    if (resolvedTemplate == null) return null;

    return _resolveCalendarUrl((
      value: resolvedTemplate,
      eventUid: validUid,
      hasUidPlaceholder: hasUidPlaceholder,
    ));
  }
}

extension on String? {
  String? get _trimmedNonEmpty {
    final value = this;
    if (value == null) return null;

    final normalizedValue = value.trim();
    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  String? get _validEventUid {
    final value = this;
    if (value == null || value.trim().isEmpty) return null;
    if (value == '.' || value == '..') return null;
    return value;
  }
}

extension on String {
  Uri? get _calendarUri => WebUriParser.tryParse(
    this,
    options: const WebUriParseOptions(
      inferMissingScheme: true,
      allowHttpLocalhost: true,
    ),
  );
}

typedef _ResolvedCalendarUrl = ({
  String value,
  String eventUid,
  bool hasUidPlaceholder,
});

String? _resolveCalendarUrl(_ResolvedCalendarUrl resolvedUrl) {
  final resolvedUri = resolvedUrl.value._calendarUri;
  if (resolvedUri == null) return null;
  return resolvedUrl.hasUidPlaceholder
      ? resolvedUri.toString()
      : _appendEventPath(resolvedUri, resolvedUrl.eventUid);
}

String _appendEventPath(Uri baseUri, String eventUid) {
  final pathSegments = baseUri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (pathSegments.isEmpty || pathSegments.last != _eventsPathSegment) {
    pathSegments.add(_eventsPathSegment);
  }
  pathSegments.add(eventUid);
  return baseUri.replace(pathSegments: pathSegments).toString();
}
