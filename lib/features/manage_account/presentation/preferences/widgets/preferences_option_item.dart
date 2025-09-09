import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/widget/default_switch_icon_widget.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapPreferencesOptionAction = Function(PreferencesOptionType optionType, bool isEnabled);

class PreferencesOptionItem extends StatelessWidget {

  final ImagePaths imagePaths;
  final TMailServerSettingOptions? settingOption;
  final PreferencesSetting preferencesSetting;
  final PreferencesOptionType optionType;
  final OnTapPreferencesOptionAction onTapPreferencesOptionAction;

  const PreferencesOptionItem({
    super.key,
    required this.imagePaths,
    required this.settingOption,
    required this.preferencesSetting,
    required this.optionType,
    required this.onTapPreferencesOptionAction,
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
              color: AppColor.gray424244.withValues(alpha: 0.64),
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              key: ValueKey(optionType.getTitle(appLocalizations)),
              onTap: () => onTapPreferencesOptionAction(
                optionType,
                optionType.isEnabled(settingOption, preferencesSetting),
              ),
              child: DefaultSwitchIconWidget(
                key: ValueKey(
                  optionType.isEnabled(settingOption, preferencesSetting)
                      ? 'setting_option_switch_on'
                      : 'setting_option_switch_off',
                ),
                imagePaths: imagePaths,
                isEnabled: optionType.isEnabled(settingOption, preferencesSetting),
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
