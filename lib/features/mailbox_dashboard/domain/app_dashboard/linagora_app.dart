import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'linagora_app.g.dart';

@JsonSerializable()
class LinagoraApp with EquatableMixin{
  @JsonKey(name: 'appName')
  final String appName;

  @JsonKey(name: 'icon')
  final String iconName;

  @JsonKey(name: 'appLink')
  final Uri appUri;

  LinagoraApp(this.appName, this.iconName, this.appUri);

  factory LinagoraApp.fromJson(Map<String, dynamic> json) => _$LinagoraAppFromJson(json);

  Map<String, dynamic> toJson() => _$LinagoraAppToJson(this);

  @override
  List<Object?> get props => [appName, iconName, appUri];
}