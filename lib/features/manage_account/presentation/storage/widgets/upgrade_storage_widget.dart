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
  final VoidCallback onUpgradeStorageAction;

  const UpgradeStorageWidget({
    super.key,
    required this.imagePaths,
    required this.onUpgradeStorageAction,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return SizedBox(
      width: isMobile ? double.infinity : 439,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minWidth: 179),
            height: 48,
            child: ConfirmDialogButton(
              label: appLocalizations.upgradeStorage,
              backgroundColor: AppColor.primaryMain,
              textColor: Colors.white,
              onTapAction: onUpgradeStorageAction,
            ),
          ),
        ],
      ),
    );
  }
}
