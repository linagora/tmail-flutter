import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_detail/local_setting_detail.dart';

part 'thread_detail_local_setting_detail.g.dart';

@JsonSerializable()
class ThreadDetailLocalSettingDetail extends LocalSettingDetail<bool> {
  static const settingType = 'threadDetailLocalSettingDetail';

  const ThreadDetailLocalSettingDetail(
    super.value, [
    this.type = settingType,
  ]);

  @JsonKey(defaultValue: settingType)
  final String type;

  factory ThreadDetailLocalSettingDetail.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailLocalSettingDetailFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreadDetailLocalSettingDetailToJson(this);

  @override
  List<Object?> get props => [value, type];
}