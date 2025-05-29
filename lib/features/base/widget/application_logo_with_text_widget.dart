import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ApplicationLogoWidthTextWidget extends StatelessWidget {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  final VoidCallback? onTapAction;
  final EdgeInsetsGeometry? margin;
  final double? iconSize;

  ApplicationLogoWidthTextWidget({
    super.key,
    this.onTapAction,
    this.margin,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: PlatformInfo.isWeb && AppConfig.isSaasPlatForm
        ? _imagePaths.icLogoWithTextBeta
        : _imagePaths.icLogoWithText,
      iconSize: iconSize ?? 33,
      padding: EdgeInsets.zero,
      margin: margin,
      backgroundColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTapActionCallback: onTapAction,
    );
  }
}