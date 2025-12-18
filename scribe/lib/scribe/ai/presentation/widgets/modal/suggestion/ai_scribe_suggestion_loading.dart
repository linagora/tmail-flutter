import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scribe/scribe.dart';

class AiScribeSuggestionLoading extends StatelessWidget {
  final ImagePaths imagePaths;

  const AiScribeSuggestionLoading({
    super.key,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 8),
      child: Row(
        spacing: 8,
        children: [
          _SparklePulseIcon(
            asset: imagePaths.icSparkle,
            color: AppColor.blue00B7FF,
          ),
          Expanded(
            child: _AnimatedEllipsisText(
              text: ScribeLocalizations.of(context).generatingResponse,
              style: AIScribeTextStyles.suggestionLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklePulseIcon extends StatefulWidget {
  final String asset;
  final Color color;

  const _SparklePulseIcon({
    required this.asset,
    required this.color,
  });

  @override
  State<_SparklePulseIcon> createState() => _SparklePulseIconState();
}

class _SparklePulseIconState extends State<_SparklePulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacity = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: SvgPicture.asset(
          widget.asset,
          width: 22,
          height: 22,
          colorFilter: widget.color.asFilter(),
        ),
      ),
    );
  }
}

class _AnimatedEllipsisText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _AnimatedEllipsisText({
    required this.text,
    required this.style,
  });

  @override
  State<_AnimatedEllipsisText> createState() => _AnimatedEllipsisTextState();
}

class _AnimatedEllipsisTextState extends State<_AnimatedEllipsisText> {
  static const _dotStates = ['', '.', '..', '...'];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _dotStates.length);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.text}${_dotStates[_index]}',
      style: widget.style,
    );
  }
}
