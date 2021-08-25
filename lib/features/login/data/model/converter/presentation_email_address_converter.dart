import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

class PresentationEmailAddressConverter implements JsonConverter<PresentationEmailAddress, String> {
  const PresentationEmailAddressConverter();

  @override
  PresentationEmailAddress fromJson(String json) => PresentationEmailAddress(json);

  @override
  String toJson(PresentationEmailAddress object) => object.email;
}
