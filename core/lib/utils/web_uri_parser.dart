final _domainLabelPattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
  caseSensitive: false,
);
final _asciiLetterPattern = RegExp('[a-z]', caseSensitive: false);
const _maximumPort = 65535;

abstract final class WebUriParser {
  static Uri? tryParse(
    String? value, {
    bool inferMissingScheme = false,
    bool allowHttpLocalhost = false,
  }) {
    final normalizedValue = _normalize(value);
    if (normalizedValue == null) return null;

    final candidate = inferMissingScheme
        ? _withSupportedScheme(normalizedValue)
        : normalizedValue;
    final uri = Uri.tryParse(candidate);
    if (uri == null) return null;
    if (!_hasValidAuthority(uri)) return null;
    if (!_hasSupportedScheme(uri, allowHttpLocalhost)) return null;
    return uri;
  }
}

String? _normalize(String? value) {
  if (value == null) return null;

  final normalizedValue = value.trim();
  if (normalizedValue.isEmpty) return null;
  return normalizedValue;
}

bool _hasValidAuthority(Uri uri) {
  if (uri.host.isEmpty) return false;
  if (uri.userInfo.isNotEmpty) return false;
  if (!uri.hasPort) return true;
  return uri.port <= _maximumPort;
}

bool _hasSupportedScheme(Uri uri, bool allowHttpLocalhost) {
  switch (uri.scheme.toLowerCase()) {
    case 'https':
      return true;
    case 'http':
      return _isAllowedHttpUri(uri, allowHttpLocalhost);
    default:
      return false;
  }
}

bool _isAllowedHttpUri(Uri uri, bool allowHttpLocalhost) {
  if (!allowHttpLocalhost) return false;
  return uri.host.toLowerCase() == 'localhost';
}

String _withSupportedScheme(String value) {
  if (value.toLowerCase().startsWith('localhost')) {
    return 'http://$value';
  }

  final inferredValue = _withHttpsScheme(value);
  if (_hasQualifiedDomain(Uri.tryParse(inferredValue))) return inferredValue;
  return value;
}

String _withHttpsScheme(String value) {
  if (value.startsWith('//')) return 'https:$value';
  return 'https://$value';
}

bool _hasQualifiedDomain(Uri? uri) {
  if (uri == null) return false;
  if (uri.userInfo.isNotEmpty) return false;
  return _isQualifiedDomain(uri.host);
}

bool _isQualifiedDomain(String host) {
  if (host.length > 253) return false;

  final labels = host.split('.');
  if (labels.length <= 1) return false;
  if (!labels.every(_domainLabelPattern.hasMatch)) return false;
  return _asciiLetterPattern.hasMatch(labels.last);
}
