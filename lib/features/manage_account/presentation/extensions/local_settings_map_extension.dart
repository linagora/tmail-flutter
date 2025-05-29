import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_detail/thread_detail_local_setting_detail.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

extension LocalSettingsMapExtension on Map<SupportedLocalSetting, LocalSettingOptions?> {
  bool? get threadDetailEnabled => (this[SupportedLocalSetting.threadDetail]?.setting as ThreadDetailLocalSettingDetail?)?.value;
}