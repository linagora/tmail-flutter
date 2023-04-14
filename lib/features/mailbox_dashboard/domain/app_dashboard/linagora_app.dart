import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'linagora_app.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LinagoraApp with EquatableMixin{
  @JsonKey(name: 'appName')
  final String appName;

  @JsonKey(name: 'icon')
  final String iconName;

  @JsonKey(name: 'appLink')
  final Uri appUri;

  final String? androidPackageId;
  final String? iosUrlScheme;
  final String? iosAppStoreLink;

  LinagoraApp(
    this.appName,
    this.iconName,
    this.appUri,
    {
      this.androidPackageId,
      this.iosUrlScheme,
      this.iosAppStoreLink
    }
  );

  factory LinagoraApp.fromJson(Map<String, dynamic> json) => _$LinagoraAppFromJson(json);

  Map<String, dynamic> toJson() => _$LinagoraAppToJson(this);

  @override
  List<Object?> get props => [
    appName,
    iconName,
    appUri,
    androidPackageId,
    iosUrlScheme,
    iosAppStoreLink
  ];
}