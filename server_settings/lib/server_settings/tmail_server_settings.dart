import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:server_settings/server_settings/converter/boolean_nullable_converter.dart';
import 'package:server_settings/server_settings/converter/server_settings_id_nullable_converter.dart';
import 'package:server_settings/server_settings/server_settings.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';

part 'tmail_server_settings.g.dart';

@JsonSerializable(
  explicitToJson: true, 
  includeIfNull: false, 
  converters: [ServerSettingsIdNullableConverter()])
class TMailServerSettings extends ServerSettings {
  final ServerSettingsId? id;
  final TMailServerSettingOptions? settings;
  TMailServerSettings({this.id, this.settings});

  factory TMailServerSettings.fromJson(Map<String, dynamic> json) =>
    _$TMailServerSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TMailServerSettingsToJson(this);

  @override
  List<Object?> get props => [id, settings];
}

@JsonSerializable(
  explicitToJson: true, 
  includeIfNull: false,
  converters: [BooleanNullableConverter()]
)
class TMailServerSettingOptions with EquatableMixin {
  @JsonKey(name: 'read.receipts.always')
  final bool? alwaysReadReceipts;

  @JsonKey(name: 'display.sender.priority')
  final bool? displaySenderPriority;

  @JsonKey(name: 'language')
  final String? language;

  @JsonKey(name: 'ai.needs-action.enabled')
  final bool? aiNeedsActionEnabled;

  TMailServerSettingOptions({
    this.alwaysReadReceipts,
    this.displaySenderPriority,
    this.language,
    this.aiNeedsActionEnabled,
  });

  factory TMailServerSettingOptions.fromJson(Map<String, dynamic> json) =>
    _$TMailServerSettingOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TMailServerSettingOptionsToJson(this);

  TMailServerSettingOptions copyWith({
    bool? alwaysReadReceipts,
    bool? displaySenderPriority,
    String? language,
    bool? aiNeedsActionEnabled,
  }) {
    return TMailServerSettingOptions(
      alwaysReadReceipts: alwaysReadReceipts ?? this.alwaysReadReceipts,
      displaySenderPriority: displaySenderPriority ?? this.displaySenderPriority,
      language: language ?? this.language,
      aiNeedsActionEnabled: aiNeedsActionEnabled ?? this.aiNeedsActionEnabled,
    );
  }

  @override
  List<Object?> get props => [
    alwaysReadReceipts,
    displaySenderPriority,
    language,
    aiNeedsActionEnabled,
  ];
}
