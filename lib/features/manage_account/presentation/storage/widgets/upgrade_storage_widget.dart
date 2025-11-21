import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class UpgradeStorageWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isMobile;
  final bool isPremiumAvailable;
  final bool isQuotaExceeds90Percent;
  final VoidCallback onUpgradeStorageAction;

  const UpgradeStorageWidget({
    super.key,
    required this.imagePaths,
    required this.onUpgradeStorageAction,
    this.isMobile = false,
    this.isPremiumAvailable = false,
    this.isQuotaExceeds90Percent = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final widgets = [
      if (isQuotaExceeds90Percent) _buildWarning(context, appLocalizations),
      if (isPremiumAvailable) _buildUpgradeButton(appLocalizations),
    ];

    if (widgets.isEmpty) return const SizedBox.shrink();

    final body = widgets.length == 1
        ? widgets.first
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          );

    return isQuotaExceeds90Percent
        ? SizedBox(
            width: isMobile ? double.infinity : 439,
            child: body,
          )
        : body;
  }

  Widget _buildWarning(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          imagePaths.icWarning,
          width: 16,
          height: 16,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            appLocalizations.storageIsAlmostFullMessage,
            style: ThemeUtils.textStyleInter600().copyWith(
              color: AppColor.m3Neutral40,
              fontSize: 12,
              height: 16 / 12,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(AppLocalizations appLocalizations) {
    return Container(
      margin: isQuotaExceeds90Percent
          ? const EdgeInsetsDirectional.only(top: 16)
          : null,
      height: 48,
      constraints: const BoxConstraints(minWidth: 179),
      child: ConfirmDialogButton(
        label: appLocalizations.upgradeStorage,
        backgroundColor: AppColor.primaryMain,
        textColor: Colors.white,
        onTapAction: onUpgradeStorageAction,
      ),
    );
  }
}
