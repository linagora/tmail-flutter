import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'capability_server_settings.g.dart';

final capabilityServerSettings = CapabilityIdentifier(Uri.parse('com:linagora:params:jmap:settings'));

@JsonSerializable()
class SettingsCapability extends CapabilityProperties {
  SettingsCapability({this.readOnlyProperties});

  final List<String>? readOnlyProperties;

  factory SettingsCapability.fromJson(Map<String, dynamic> json) =>
      _$SettingsCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsCapabilityToJson(this);

  factory SettingsCapability.deserialize(Map<String, dynamic> json) {
    return SettingsCapability.fromJson(json);
  }
  
  @override
  List<Object?> get props => [readOnlyProperties];
}