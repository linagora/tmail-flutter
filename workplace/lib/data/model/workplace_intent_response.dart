import 'workplace_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workplace_intent_response.g.dart';

@JsonSerializable(createToJson: false)
final class WorkplaceIntentAttributesResponse {
  final WorkplaceAction action;
  final String type;
  final List<WorkplacePermission> permissions;
  final List<WorkplaceIntentServiceResponse> services;
  final String? client;
  final List<String>? availableApps;

  const WorkplaceIntentAttributesResponse({
    required this.action,
    required this.type,
    required this.permissions,
    required this.services,
    this.client,
    this.availableApps,
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
final class WorkplaceIntentMetaResponse {
  final String? rev;

  const WorkplaceIntentMetaResponse({this.rev});

  factory WorkplaceIntentMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentMetaResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class WorkplaceIntentLinksResponse {
  final String? self;
  final String? permissions;

  const WorkplaceIntentLinksResponse({this.self, this.permissions});

  factory WorkplaceIntentLinksResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceIntentLinksResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
final class WorkplaceIntentDataResponse {
  final String id;
  final String? type;
  final WorkplaceIntentAttributesResponse attributes;
  final WorkplaceIntentMetaResponse? meta;
  final WorkplaceIntentLinksResponse? links;

  const WorkplaceIntentDataResponse({
    required this.id,
    this.type,
    required this.attributes,
    this.meta,
    this.links,
  });

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
