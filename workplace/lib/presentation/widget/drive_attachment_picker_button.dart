import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class DriveAttachmentPickerButton extends StatelessWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri? workplaceUri;
  final String? tooltipLabel;
  final Color? iconColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DriveAttachmentPickerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    this.tooltipLabel,
    this.iconColor,
    this.iconSize = 20,
    this.borderRadius = 20,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (workplaceUri == null) return const SizedBox.shrink();
    return TMailButtonWidget.fromIcon(
      icon: imagePaths.icCloudPlus,
      iconColor: iconColor,
      backgroundColor: Colors.transparent,
      iconSize: iconSize,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      tooltipMessage: tooltipLabel,
      onTapActionCallback: () {},
    );
  }
}
