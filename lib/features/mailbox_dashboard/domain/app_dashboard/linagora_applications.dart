import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'linagora_app.dart';

part 'linagora_applications.g.dart';

@JsonSerializable()
class LinagoraApplications with EquatableMixin {
  @JsonKey(name: 'apps')
  final List<LinagoraApp> apps;

  LinagoraApplications(this.apps);

  factory LinagoraApplications.fromJson(Map<String, dynamic> json) => _$LinagoraApplicationsFromJson(json);

  Map<String, dynamic> toJson() => _$LinagoraApplicationsToJson(this);

  @override
  List<Object?> get props => [apps];
}