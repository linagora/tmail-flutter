import 'workplace_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workplace_intent_response.g.dart';

@JsonSerializable(createToJson: false)
final class WorkplaceIntentAttributesResponse {
  final WorkplaceAction action;
  final String type;
  final List<WorkplacePermission> permissions;
  final List<WorkplaceIntentServiceResponse> services;

  const WorkplaceIntentAttributesResponse({
    required this.action,
    required this.type,
    required this.permissions,
    required this.services,
  });

  factory WorkplaceIntentAttributesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentAttributesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class WorkplaceIntentServiceResponse {
  final String href;

  const WorkplaceIntentServiceResponse({required this.href});

  factory WorkplaceIntentServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentServiceResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class WorkplaceIntentDataResponse {
  final String id;
  final WorkplaceIntentAttributesResponse attributes;

  const WorkplaceIntentDataResponse({required this.id, required this.attributes});

  factory WorkplaceIntentDataResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentDataResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class WorkplaceIntentResponse {
  final WorkplaceIntentDataResponse data;

  const WorkplaceIntentResponse({required this.data});

  factory WorkplaceIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentResponseFromJson(json);
}
