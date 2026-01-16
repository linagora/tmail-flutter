import 'package:json_annotation/json_annotation.dart';
import 'package:labels/model/hex_color.dart';

class HexColorNullableConverter implements JsonConverter<HexColor?, String?> {
  const HexColorNullableConverter();

  @override
  HexColor? fromJson(String? json) => json != null ? HexColor(json) : null;

  @override
  String? toJson(HexColor? object) => object?.value;
}
