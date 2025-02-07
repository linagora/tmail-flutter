import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'download_all_capability.g.dart';

@JsonSerializable(includeIfNull: false)
class DownloadAllCapability extends CapabilityProperties {
  DownloadAllCapability({this.endpoint});

  final String? endpoint;

  factory DownloadAllCapability.fromJson(Map<String, dynamic> json) => _$DownloadAllCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadAllCapabilityToJson(this);

  factory DownloadAllCapability.deserialize(Map<String, dynamic> json) => _$DownloadAllCapabilityFromJson(json);

  @override
  List<Object?> get props => [endpoint];
}
