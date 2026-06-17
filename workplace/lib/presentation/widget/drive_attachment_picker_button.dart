import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class DriveAttachmentPickerButton extends StatelessWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri? workplaceUri;
  final ComposerToolbarButtonStyle style;

  const DriveAttachmentPickerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    this.style = const ComposerToolbarButtonStyle(),
  });

  @override
  Widget build(BuildContext context) {
    if (workplaceUri == null) return const SizedBox.shrink();
    return TMailButtonWidget.fromIcon(
      icon: imagePaths.icCloudPlus,
      iconColor: style.iconColor,
      backgroundColor: Colors.transparent,
      iconSize: style.iconSize,
      borderRadius: style.borderRadius,
      padding: style.padding,
      margin: style.margin,
      tooltipMessage: style.tooltipLabel,
      onTapActionCallback: () {},
    );
  }
}
