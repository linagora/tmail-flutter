import 'package:drive_attachment/drive_attachment/data/model/drive_intent_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drive_intent_response.g.dart';

@JsonSerializable(createToJson: false)
final class DriveIntentAttributesResponse {
  final DriveIntentAction action;
  final String type;
  final List<DriveIntentPermission> permissions;
  final List<DriveIntentServiceResponse> services;

  const DriveIntentAttributesResponse({
    required this.action,
    required this.type,
    required this.permissions,
    required this.services,
  });

  factory DriveIntentAttributesResponse.fromJson(Map<String, dynamic> json) =>
      _$DriveIntentAttributesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class DriveIntentServiceResponse {
  final String href;

  const DriveIntentServiceResponse({required this.href});

  factory DriveIntentServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$DriveIntentServiceResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class DriveIntentDataResponse {
  final String id;
  final DriveIntentAttributesResponse attributes;

  const DriveIntentDataResponse({required this.id, required this.attributes});

  factory DriveIntentDataResponse.fromJson(Map<String, dynamic> json) =>
      _$DriveIntentDataResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class DriveIntentResponse {
  final DriveIntentDataResponse data;

  const DriveIntentResponse({required this.data});

  factory DriveIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$DriveIntentResponseFromJson(json);
}
