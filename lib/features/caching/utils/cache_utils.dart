
import 'dart:convert';

import 'package:core/utils/app_logger.dart';

class CacheUtils {
  static String encodeKey(String key) {
    final keyEncoded = base64.encode(utf8.encode(key));
    log('CacheUtils::encodeKey():keyHashed: $keyEncoded');
    return keyEncoded;
  }

  static String decodeKey(String keyEncoded) {
    final keyDecoded = utf8.decode(base64.decode(keyEncoded));
    log('CacheUtils::decodeKey():keyDecoded: $keyDecoded');
    return keyDecoded;
  }
}

class TupleKey {
  final List<String> parts;

  TupleKey(
    String key1,
    [
      String? key2,
      String? key3
    ]
  ) : parts = [
    key1,
    if (key2 != null) key2,
    if (key3 != null) key3,
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