class StringConvert {
  static String? writeEmptyToNull(String text) {
    if (text.isEmpty) return null;
    return text;
  }

  static String writeNullToEmpty(String? text) {
    return text ?? '';
  }

  static String toUrlScheme(String hotScheme) {
    return '$hotScheme://';
  }
}
