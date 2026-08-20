import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_from_url_capability.g.dart';

@JsonSerializable(includeIfNull: false)
class UploadFromUrlCapability extends CapabilityProperties {
  UploadFromUrlCapability({this.uploadUrl});

  /// The upload-from-url endpoint advertised by the server, still holding its `{accountId}` template variable.
  final Uri? uploadUrl;

  factory UploadFromUrlCapability.fromJson(Map<String, dynamic> json) => _$UploadFromUrlCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$UploadFromUrlCapabilityToJson(this);

  factory UploadFromUrlCapability.deserialize(Map<String, dynamic> json) => _$UploadFromUrlCapabilityFromJson(json);

  @override
  List<Object?> get props => [uploadUrl];
}
