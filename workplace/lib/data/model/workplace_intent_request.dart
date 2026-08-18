import 'workplace_enums.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/workplace_action_config.dart';
import '../../domain/entity/workplace_theme.dart';

part 'workplace_intent_request.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class WorkplaceActionConfigRequest {
  final String? label;
  final num? maxFileSize;
  final num? availableSize;

  const WorkplaceActionConfigRequest({
    this.label,
    this.maxFileSize,
    this.availableSize,
  });

  factory WorkplaceActionConfigRequest.fromEntity(
    WorkplaceActionConfig config,
  ) => WorkplaceActionConfigRequest(
    label: config.label,
    maxFileSize: config.maxFileSize,
    availableSize: config.availableSize,
  );

  Map<String, dynamic> toJson() => _$WorkplaceActionConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class WorkplaceThemeConfigRequest {
  final WorkplaceThemeType type;

  const WorkplaceThemeConfigRequest({required this.type});

  factory WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme theme) =>
      WorkplaceThemeConfigRequest(
        type: switch (theme) {
          WorkplaceTheme.light => WorkplaceThemeType.light,
          WorkplaceTheme.dark => WorkplaceThemeType.dark,
        },
      );

  Map<String, dynamic> toJson() => _$WorkplaceThemeConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceFilePickerConfigRequest {
  final WorkplaceActionConfigRequest sharingLink;
  final WorkplaceActionConfigRequest? downloadLink;
  final WorkplaceThemeConfigRequest theme;

  const WorkplaceFilePickerConfigRequest({
    required this.sharingLink,
    required this.downloadLink,
    required this.theme,
  });

  Map<String, dynamic> toJson() =>
      _$WorkplaceFilePickerConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceIntentAttributesRequest {
  final WorkplaceAction action;
  final WorkplaceDocType type;
  final List<WorkplacePermission> permissions;
  final WorkplaceFilePickerConfigRequest data;

  const WorkplaceIntentAttributesRequest({
    required this.action,
    required this.type,
    required this.permissions,
    required this.data,
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
