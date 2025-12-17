import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

typedef OnOpenAiAssistantModal = void Function(
  Offset? position,
  Size? size,
);

class AiAssistantButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final OnOpenAiAssistantModal onOpenAiAssistantModal;

  const AiAssistantButton({
    super.key,
    required this.imagePaths,
    required this.onOpenAiAssistantModal,
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
      onTapActionCallback: () => _onTapActionCallback(context),
    );
  }

  void _onTapActionCallback(BuildContext context) {
    final renderBox = context.findRenderObject();

    Offset? position;
    Size? size;

    if (renderBox != null && renderBox is RenderBox) {
      position = renderBox.localToGlobal(Offset.zero);
      size = renderBox.size;
    }

    onOpenAiAssistantModal(position, size);
  }
}
