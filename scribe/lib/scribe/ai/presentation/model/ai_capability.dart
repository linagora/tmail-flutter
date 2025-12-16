import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_capability.g.dart';

@JsonSerializable(includeIfNull: false)
class AICapability extends CapabilityProperties {
  AICapability({this.scribeEndpoint});

  final String? scribeEndpoint;

  factory AICapability.fromJson(Map<String, dynamic> json) => _$AICapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AICapabilityToJson(this);

  factory AICapability.deserialize(Map<String, dynamic> json) => _$AICapabilityFromJson(json);

  @override
  List<Object?> get props => [scribeEndpoint];
}
