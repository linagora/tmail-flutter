import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HighlightSVGIconOnHover extends StatefulWidget {
  final String icon;
  final double size;
  final double borderRadius;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final String? tooltipMessage;

  const HighlightSVGIconOnHover({
    Key? key,
    required this.icon,
    this.size = 20.0,
    this.borderRadius = 5.0,
    this.iconColor,
    this.padding,
    this.tooltipMessage,
  }) : super(key: key);

  @override
  State<HighlightSVGIconOnHover> createState() => _HighlightSVGIconOnHoverState();
}

class _HighlightSVGIconOnHoverState extends State<HighlightSVGIconOnHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final child = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          color: _isHovered ? Theme.of(context).hoverColor : null,
        ),
        padding: widget.padding ?? const EdgeInsets.all(5),
        child: SvgPicture.asset(
          widget.icon,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.fill,
          colorFilter: widget.iconColor?.asFilter(),
        ),
      ),
    );

    if (widget.tooltipMessage != null) {
      return Tooltip(
        message: widget.tooltipMessage,
        child: child,
      );
    }
    return child;
  }
}