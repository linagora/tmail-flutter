import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_detail/thread_detail_local_setting_detail.dart';

abstract class LocalSettingDetail<T> extends Equatable {
  const LocalSettingDetail(this.value);

  final T value;

  Map<String, dynamic> toJson();
}

class LocalSettingDetailConverter extends JsonConverter<LocalSettingDetail, Map<String, dynamic>> {
  const LocalSettingDetailConverter();

  @override
  LocalSettingDetail fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case ThreadDetailLocalSettingDetail.settingType:
        return ThreadDetailLocalSettingDetail.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Map<String, dynamic> toJson(LocalSettingDetail object) {
    return object.toJson();
  }
}