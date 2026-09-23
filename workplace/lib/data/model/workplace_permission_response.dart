import 'package:json_annotation/json_annotation.dart';

part 'workplace_permission_response.g.dart';

@JsonSerializable(createToJson: false)
class WorkplaceShortcodesResponse {
  final String? code;

  const WorkplaceShortcodesResponse({this.code});

  factory WorkplaceShortcodesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceShortcodesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class WorkplacePermissionAttributesResponse {
  final WorkplaceShortcodesResponse? shortcodes;

  const WorkplacePermissionAttributesResponse({this.shortcodes});

  factory WorkplacePermissionAttributesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplacePermissionAttributesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class WorkplacePermissionDataResponse {
  final String? id;
  final WorkplacePermissionAttributesResponse attributes;

  const WorkplacePermissionDataResponse({this.id, required this.attributes});

  factory WorkplacePermissionDataResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplacePermissionDataResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class WorkplacePermissionResponse {
  final WorkplacePermissionDataResponse data;

  const WorkplacePermissionResponse({required this.data});

  factory WorkplacePermissionResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplacePermissionResponseFromJson(json);
}
