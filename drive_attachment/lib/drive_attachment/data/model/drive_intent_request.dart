import 'package:drive_attachment/drive_attachment/data/model/drive_intent_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drive_intent_request.g.dart';

@JsonSerializable(createFactory: false)
class DriveIntentAttributesRequest {
  final DriveIntentAction action;
  final String type;
  final List<DriveIntentPermission> permissions;

  const DriveIntentAttributesRequest({
    required this.action,
    required this.type,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => _$DriveIntentAttributesRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class DriveIntentDataRequest {
  final String type;
  final DriveIntentAttributesRequest attributes;

  const DriveIntentDataRequest({
    required this.type,
    required this.attributes,
  });

  Map<String, dynamic> toJson() => _$DriveIntentDataRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class DriveIntentRequest {
  final DriveIntentDataRequest data;

  const DriveIntentRequest({required this.data});

  Map<String, dynamic> toJson() => _$DriveIntentRequestToJson(this);
}
