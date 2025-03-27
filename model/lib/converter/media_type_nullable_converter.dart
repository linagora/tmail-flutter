import 'package:http_parser/http_parser.dart';
import 'package:json_annotation/json_annotation.dart';

class MediaTypeNullableConverter implements JsonConverter<MediaType?, String?> {
  const MediaTypeNullableConverter();

  @override
  MediaType? fromJson(String? json) => json != null ? MediaType.parse(json) : null;

  @override
  String? toJson(MediaType? object) => object?.type;
}