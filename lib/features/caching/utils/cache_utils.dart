
import 'dart:convert';

class CacheUtils {
  static String encodeKey(String key) => base64.encode(utf8.encode(key));

  static String decodeKey(String keyEncoded) => utf8.decode(base64.decode(keyEncoded));
}

class TupleKey {
  final List<String> parts;

  TupleKey(
    String key1,
    String key2,
    [
      String? key3,
      String? key4,
    ]
  ) : parts = [
    key1,
    key2,
    if (key3 != null) key3,
    if (key4 != null) key4,
  ];

  const TupleKey.byParts(this.parts);

  TupleKey.fromString(String multiKeyString) : parts = multiKeyString.split('|').toList();

  @override
  String toString() => parts.join('|');

  @override
  bool operator ==(other) => parts.toString() == other.toString();

  @override
  int get hashCode => Object.hashAll(parts);

  String get encodeKey => CacheUtils.encodeKey(toString());
}