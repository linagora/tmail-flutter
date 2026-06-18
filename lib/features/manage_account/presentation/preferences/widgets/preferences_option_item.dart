import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/base/widget/default_switch_icon_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_preferences_revealed_provider.dart';

typedef OnTapPreferencesOptionAction =
    Function(PreferenceOption option, bool currentValue);

class PreferencesOptionItem extends ConsumerWidget {
  final ImagePaths imagePaths;
  final PreferenceOption option;
  final PreferencesContext preferencesContext;
  final OnTapPreferencesOptionAction onTapPreferencesOptionAction;

  const PreferencesOptionItem({
    super.key,
    required this.imagePaths,
    required this.option,
    required this.preferencesContext,
    required this.onTapPreferencesOptionAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final isEnabled = option.isEnabled(preferencesContext);
    final isExperimental = option.isExperimental;
    final revealed =
        ref.watch(experimentalPreferencesRevealedProvider).asData?.value ??
        false;
    if (isExperimental && !revealed) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.title(appLocalizations),
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
            option.explanation(appLocalizations),
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
              key: ValueKey(option.title(appLocalizations)),
              onTap: () => onTapPreferencesOptionAction(option, isEnabled),
              child: DefaultSwitchIconWidget(
                key: ValueKey(
                  isEnabled
                      ? 'setting_option_switch_on'
                      : 'setting_option_switch_off',
                ),
                imagePaths: imagePaths,
                isEnabled: isEnabled,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.toggleDescription(appLocalizations),
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
