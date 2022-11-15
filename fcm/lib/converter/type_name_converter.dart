import 'package:fcm/model/type_name.dart';
import 'package:json_annotation/json_annotation.dart';

class TypeNameConverter implements JsonConverter<TypeName, String> {
  const TypeNameConverter();

  @override
  TypeName fromJson(String json) => TypeName(json);

  @override
  String toJson(TypeName object) => object.value;
}
