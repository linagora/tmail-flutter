import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autocomplete_capability.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  converters: [
    UnsignedIntNullableConverter()
  ]
)
class AutocompleteCapability extends CapabilityProperties {
  final UnsignedInt? minInputLength;

  AutocompleteCapability({this.minInputLength});
  
  factory AutocompleteCapability.fromJson(Map<String, dynamic> json) 
    => _$AutocompleteCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AutocompleteCapabilityToJson(this);

  static AutocompleteCapability deserialize(Map<String, dynamic> json) {
    return AutocompleteCapability.fromJson(json);
  }
  
  @override
  List<Object?> get props => [minInputLength];
}