import 'package:json_annotation/json_annotation.dart';

class BooleanNullableConverter implements JsonConverter<bool?, String?> {
  const BooleanNullableConverter();

  @override
  bool? fromJson(String? json) {
    if (json == null) {
      return null;
    } else if (json.trim().toLowerCase() == 'true') {
      return true;
    } else {
      return false;
    }
  }

  @override
  String? toJson(bool? object) => object?.toString();
}