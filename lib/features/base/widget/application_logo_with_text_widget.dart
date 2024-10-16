import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationLogoWidthTextWidget extends StatelessWidget {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  final VoidCallback? onTapAction;
  final EdgeInsetsGeometry? margin;

  ApplicationLogoWidthTextWidget({
    super.key,
    this.onTapAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: _imagePaths.icLogoWithText,
      iconSize: 33,
      padding: EdgeInsets.zero,
      margin: margin,
      backgroundColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTapActionCallback: onTapAction,
    );
  }
}