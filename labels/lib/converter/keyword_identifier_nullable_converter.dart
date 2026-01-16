import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:json_annotation/json_annotation.dart';

class KeywordIdentifierNullableConverter
    implements JsonConverter<KeyWordIdentifier?, String?> {
  const KeywordIdentifierNullableConverter();

  @override
  KeyWordIdentifier? fromJson(String? json) =>
      json != null ? KeyWordIdentifier(json) : null;

  @override
  String? toJson(KeyWordIdentifier? object) => object?.value;
}
