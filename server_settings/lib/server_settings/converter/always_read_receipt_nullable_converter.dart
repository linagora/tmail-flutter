import 'package:json_annotation/json_annotation.dart';

class AlwaysReadReceiptNullableConverter implements JsonConverter<bool?, String?> {
  const AlwaysReadReceiptNullableConverter();

  @override
  bool? fromJson(String? json) {
    if (json == null) {
      return null;
    } else if (json == 'true') {
      return true;
    } else {
      return false;
    }
  }

  @override
  String? toJson(bool? object) => object?.toString();
}