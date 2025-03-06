
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapSettingOptionAction = Function(SettingOptionType optionType, bool isEnabled);

class SettingOptionItem extends StatelessWidget {

  final ImagePaths imagePaths;
  final TMailServerSettingOptions settingOption;
  final SettingOptionType optionType;
  final OnTapSettingOptionAction onTapSettingOptionAction;

  const SettingOptionItem({
    super.key,
    required this.imagePaths,
    required this.settingOption,
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
          style: const TextStyle(
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            optionType.getExplanation(appLocalizations),
            style: const TextStyle(
              fontSize: 13,
              height: 16 / 13,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () => onTapSettingOptionAction(
                optionType,
                optionType.isEnabled(settingOption),
              ),
              child: SvgPicture.asset(
                optionType.isEnabled(settingOption)
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
                style: const TextStyle(
                  fontSize: 13,
                  height: 16 / 13,
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
