import 'package:flutter/material.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

class AIScribeButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final VoidCallback onTap;

  const AIScribeButton({
    super.key,
    required this.imagePaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
        icon: imagePaths.icSparkle,
        padding: const EdgeInsets.all(6),
        backgroundColor: Colors.white,
        iconSize: 12,
        borderRadius: 100,
        onTapActionCallback: onTap,
        boxShadow: AIScribeShadows.elevation8,
    );
  }
}
