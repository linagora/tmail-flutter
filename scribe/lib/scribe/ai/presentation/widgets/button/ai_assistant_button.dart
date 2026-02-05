import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'ai_assistant_animated_button.dart';
import 'ai_assistant_static_button.dart';

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
    if (PlatformInfo.isWebDesktop) {
      return AiAssistantAnimatedButton(
        imagePaths: imagePaths,
        onTapActionCallback: () => _onTapActionCallback(context),
        margin: margin,
      );
    } else {
      return AiAssistantStaticButton(
        imagePaths: imagePaths,
        onTapActionCallback: () => _onTapActionCallback(context),
        iconColor: iconColor,
        margin: margin,
      );
    }
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
