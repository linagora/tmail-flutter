import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'delegation_config.g.dart';

@JsonSerializable()
class DelegationConfig extends PreferencesConfig {
  static const keySuffix = 'DELEGATION';

  final bool isEnabled;

  DelegationConfig({this.isEnabled = false});

  @override
  String get configKey => keySuffix;

  factory DelegationConfig.initial() => DelegationConfig();

  factory DelegationConfig.fromJson(Map<String, dynamic> json) =>
      _$DelegationConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DelegationConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}
