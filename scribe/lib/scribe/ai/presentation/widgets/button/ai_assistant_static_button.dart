import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiAssistantStaticButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final void Function() onTapActionCallback;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;

  const AiAssistantStaticButton({
    super.key,
    required this.imagePaths,
    required this.onTapActionCallback,
    this.iconColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: imagePaths.icGradientSparkle,
      padding: AIScribeSizes.aiAssistantIconPadding,
      backgroundColor: Colors.transparent,
      iconSize: AIScribeSizes.aiAssistantIcon,
      iconColor: iconColor,
      margin: margin,
      borderRadius: AIScribeSizes.aiAssistantIconRadius,
      tooltipMessage: ScribeLocalizations.of(context).aiAssistant,
      onTapActionCallback: onTapActionCallback,
    );
  }
}