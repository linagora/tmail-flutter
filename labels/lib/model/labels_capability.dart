import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'labels_capability.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LabelsCapability extends CapabilityProperties {
  final int? version;

  LabelsCapability({this.version});

  factory LabelsCapability.fromJson(Map<String, dynamic> json) =>
      _$LabelsCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$LabelsCapabilityToJson(this);

  static LabelsCapability deserialize(Map<String, dynamic> json) {
    return LabelsCapability.fromJson(json);
  }

  @override
  List<Object?> get props => [version];
}
