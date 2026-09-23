import 'package:json_annotation/json_annotation.dart';
import 'workplace_enums.dart';

part 'workplace_permission_request.g.dart';

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplacePermissionRuleRequest {
  final WorkplaceDocType type;
  final List<WorkplacePermission> verbs;
  final List<String> values;

  const WorkplacePermissionRuleRequest({
    required this.type,
    required this.verbs,
    required this.values,
  });

  Map<String, dynamic> toJson() => _$WorkplacePermissionRuleRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplacePermissionSetRequest {
  final WorkplacePermissionRuleRequest file;

  const WorkplacePermissionSetRequest({required this.file});

  Map<String, dynamic> toJson() => _$WorkplacePermissionSetRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplacePermissionAttributesRequest {
  final WorkplacePermissionSetRequest permissions;

  const WorkplacePermissionAttributesRequest({required this.permissions});

  Map<String, dynamic> toJson() => _$WorkplacePermissionAttributesRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplacePermissionDataRequest {
  final WorkplaceDataRequestType type;
  final WorkplacePermissionAttributesRequest attributes;

  const WorkplacePermissionDataRequest({required this.type, required this.attributes});

  Map<String, dynamic> toJson() => _$WorkplacePermissionDataRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplacePermissionRequest {
  final WorkplacePermissionDataRequest data;

  const WorkplacePermissionRequest({required this.data});

  Map<String, dynamic> toJson() => _$WorkplacePermissionRequestToJson(this);
}
