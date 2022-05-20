
import 'package:json_annotation/json_annotation.dart';

class UriConverter implements JsonConverter<Uri, String> {
  const UriConverter();

  @override
  Uri fromJson(String json) => Uri.parse(json);

  @override
  String toJson(Uri uri) => uri.path;
}