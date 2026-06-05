import 'workplace_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workplace_intent_request.g.dart';

@JsonSerializable(createFactory: false)
class WorkplaceIntentAttributesRequest {
  final WorkplaceAction action;
  final WorkplaceAttributesRequestType type;
  final List<WorkplacePermission> permissions;

  const WorkplaceIntentAttributesRequest({
    required this.action,
    required this.type,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => _$WorkplaceIntentAttributesRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class WorkplaceIntentDataRequest {
  final WorkplaceDataRequestType type;
  final WorkplaceIntentAttributesRequest attributes;

  const WorkplaceIntentDataRequest({
    required this.type,
    required this.attributes,
  });

  Map<String, dynamic> toJson() => _$WorkplaceIntentDataRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class WorkplaceIntentRequest {
  final WorkplaceIntentDataRequest data;

  const WorkplaceIntentRequest({required this.data});

  Map<String, dynamic> toJson() => _$WorkplaceIntentRequestToJson(this);
}
