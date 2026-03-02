import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scribe/scribe.dart';

class AiAssistantAnimatedButton extends StatefulWidget {
  final ImagePaths imagePaths;
  final void Function() onTapActionCallback;
  final EdgeInsetsGeometry? margin;

  const AiAssistantAnimatedButton({
    super.key,
    required this.imagePaths,
    required this.onTapActionCallback,
    this.margin,
  });

  @override
  State<AiAssistantAnimatedButton> createState() =>
      _AiAssistantAnimatedButtonState();
}

class _AiAssistantAnimatedButtonState extends State<AiAssistantAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TMailContainerWidget(
      margin: widget.margin,
      padding: AIScribeSizes.aiAssistantIconPadding,
      backgroundColor: Colors.transparent,
      borderRadius: AIScribeSizes.aiAssistantIconRadius,
      tooltipMessage: ScribeLocalizations.of(context).aiAssistant,
      onTapActionCallback: widget.onTapActionCallback,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          _animationController.forward();
        },
        onExit: (event) {
          _animationController.reset();
        },
        child: Lottie.asset(
          widget.imagePaths.animLottieScribe,
          width: AIScribeSizes.aiAssistantIcon,
          height: AIScribeSizes.aiAssistantIcon,
          fit: BoxFit.fill,
          controller: _animationController,
          onLoaded: (composition) {
            _animationController.duration = composition.duration;
          },
        ), 
      ),
    );
  }
}
