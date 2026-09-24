final _domainLabelPattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
  caseSensitive: false,
);
final _asciiLetterPattern = RegExp('[a-z]', caseSensitive: false);
const _maximumPort = 65535;

final class WebUriParseOptions {
  final bool inferMissingScheme;
  final bool allowHttpLocalhost;

  const WebUriParseOptions({
    this.inferMissingScheme = false,
    this.allowHttpLocalhost = false,
  });
}

abstract final class WebUriParser {
  static Uri? tryParse(
    String? value, {
    WebUriParseOptions options = const WebUriParseOptions(),
  }) {
    final normalizedValue = value._normalizedWebUri;
    if (normalizedValue == null) return null;
    if (!normalizedValue._hasValidPercentEscapes) return null;

    final candidate = options.inferMissingScheme
        ? normalizedValue._withSupportedScheme
        : normalizedValue;
    final uri = Uri.tryParse(candidate);
    if (uri == null) return null;
    if (!_hasValidAuthority(uri)) return null;
    if (!_hasSupportedScheme(uri, options)) return null;
    return uri;
  }
}

extension on String? {
  String? get _normalizedWebUri {
    final value = this;
    if (value == null) return null;

    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) return null;
    return normalizedValue;
  }
}

extension on String {
  bool get _hasValidPercentEscapes {
    for (var index = 0; index < length; index++) {
      if (codeUnitAt(index) != 0x25) continue;
      if (index + 2 >= length) return false;
      if (!codeUnitAt(index + 1)._isHexDigit ||
          !codeUnitAt(index + 2)._isHexDigit) {
        return false;
      }
      index += 2;
    }
    return true;
  }

  String get _withSupportedScheme {
    if (toLowerCase().startsWith('localhost')) return 'http://$this';

    final inferredValue = _withHttpsScheme;
    if (Uri.tryParse(inferredValue)._hasQualifiedDomain) return inferredValue;
    return this;
  }

  String get _withHttpsScheme =>
      startsWith('//') ? 'https:$this' : 'https://$this';

  bool get _isQualifiedDomain {
    if (length > 253) return false;

    final labels = split('.');
    if (labels.length <= 1) return false;
    if (!labels.every(_domainLabelPattern.hasMatch)) return false;
    return _asciiLetterPattern.hasMatch(labels.last);
  }
}

extension on int {
  bool get _isHexDigit =>
      this >= 0x30 && this <= 0x39 ||
      this >= 0x41 && this <= 0x46 ||
      this >= 0x61 && this <= 0x66;
}

extension on Uri? {
  bool get _hasQualifiedDomain {
    final uri = this;
    if (uri == null) return false;
    if (uri.userInfo.isNotEmpty) return false;
    return uri.host._isQualifiedDomain;
  }
}

bool _hasValidAuthority(Uri uri) {
  if (uri.host.isEmpty) return false;
  if (uri.userInfo.isNotEmpty) return false;
  if (!uri.hasPort) return true;
  return uri.port <= _maximumPort;
}

bool _hasSupportedScheme(Uri uri, WebUriParseOptions options) {
  switch (uri.scheme.toLowerCase()) {
    case 'https':
      return true;
    case 'http':
      return options.allowHttpLocalhost &&
          uri.host.toLowerCase() == 'localhost';
    default:
      return false;
  }
}
