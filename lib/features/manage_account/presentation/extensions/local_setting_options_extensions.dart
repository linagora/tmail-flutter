import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

extension LocalSettingOptionsExtensions on LocalSettingOptions {
  bool? get threadDetailEnabled => settings
    [SupportedLocalSetting.threadDetail]
    ?.value as bool?;
}