import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapSettingOptionAction = Function(SettingOptionType optionType, bool isEnabled);

class SettingOptionItem extends StatelessWidget {

  final ImagePaths imagePaths;
  final TMailServerSettingOptions? settingOption;
  final Map<SupportedLocalSetting, LocalSettingOptions?> localSettings;
  final SettingOptionType optionType;
  final OnTapSettingOptionAction onTapSettingOptionAction;

  const SettingOptionItem({
    super.key,
    required this.imagePaths,
    required this.settingOption,
    required this.localSettings,
    required this.optionType,
    required this.onTapSettingOptionAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          optionType.getTitle(appLocalizations),
          style: ThemeUtils.textStyleInter600().copyWith(
            fontSize: 14,
            height: 20 / 14,
            letterSpacing: 0.25,
            color: AppColor.gray424244,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            optionType.getExplanation(appLocalizations),
            style: ThemeUtils.textStyleInter400.copyWith(
              fontSize: 14,
              height: 21.01 / 14,
              letterSpacing: -0.15,
              color: AppColor.gray424244.withOpacity(0.64),
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              key: ValueKey(optionType.getTitle(appLocalizations)),
              onTap: () => onTapSettingOptionAction(
                optionType,
                optionType.isEnabled(settingOption, localSettings),
              ),
              child: SvgPicture.asset(
                key: ValueKey(
                  optionType.isEnabled(settingOption, localSettings)
                      ? 'setting_option_switch_on'
                      : 'setting_option_switch_off',
                ),
                optionType.isEnabled(settingOption, localSettings)
                  ? imagePaths.icSwitchOn
                  : imagePaths.icSwitchOff,
                fit: BoxFit.fill,
                width: 44,
                height: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionType.getToggleDescription(appLocalizations),
                style: ThemeUtils.textStyleBodyBody2().copyWith(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
