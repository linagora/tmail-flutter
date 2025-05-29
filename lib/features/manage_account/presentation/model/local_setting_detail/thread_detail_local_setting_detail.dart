import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_detail/local_setting_detail.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

part 'thread_detail_local_setting_detail.g.dart';

@JsonSerializable()
class ThreadDetailLocalSettingDetail extends LocalSettingDetail<bool> {
  const ThreadDetailLocalSettingDetail(
    super.value, [
    this.type = SupportedLocalSetting.threadDetail,
  ]);

  @JsonKey(defaultValue: SupportedLocalSetting.threadDetail)
  final SupportedLocalSetting type;

  factory ThreadDetailLocalSettingDetail.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailLocalSettingDetailFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreadDetailLocalSettingDetailToJson(this);

  @override
  List<Object?> get props => [value, type];
}