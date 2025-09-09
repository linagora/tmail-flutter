import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IncreaseSpaceButtonWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isDesktop;
  final VoidCallback onTapAction;
  final EdgeInsetsGeometry? margin;

  const IncreaseSpaceButtonWidget({
    super.key,
    required this.imagePaths,
    required this.onTapAction,
    this.isDesktop = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 193),
      height: 44,
      width: !isDesktop ? double.infinity : null,
      margin: margin,
      child: ConfirmDialogButton(
        label: AppLocalizations.of(context).increaseYourSpace,
        borderColor: AppColor.m3SysLightSecondaryBlue,
        icon: imagePaths.icPremium,
        iconSize: 22,
        iconColor: Colors.transparent,
        textStyle: ThemeUtils.textStyleM3BodyMedium.copyWith(
          color: AppColor.blue700,
        ),
        radius: 7,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        onTapAction: onTapAction,
      ),
    );
  }
}
