import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Replaces the material IconButton with a platform aware solution
class DensePlatformIconButton extends StatelessWidget {
  final Key? widgetKey;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final MouseCursor mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool enableFeedback;
  final BoxConstraints? constraints;
  final void Function() onPressed;
  final Widget icon;
  final double iconSize;

  const DensePlatformIconButton(
      {Key? key,
      this.widgetKey,
      this.iconSize = 24.0,
      required this.onPressed,
      required this.icon,
      this.visualDensity,
      this.padding = const EdgeInsets.all(8.0),
      this.alignment = Alignment.center,
      this.splashRadius,
      this.color,
      this.focusColor,
      this.hoverColor,
      this.highlightColor,
      this.splashColor,
      this.disabledColor,
      this.mouseCursor = SystemMouseCursors.click,
      this.focusNode,
      this.autofocus = false,
      this.tooltip,
      this.enableFeedback = true,
      this.constraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => IconButton(
        key: widgetKey,
        iconSize: iconSize,
        onPressed: onPressed,
        icon: icon,
        visualDensity: visualDensity,
        padding: padding,
        alignment: alignment,
        splashRadius: splashRadius,
        color: color,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        disabledColor: disabledColor,
        mouseCursor: mouseCursor,
        focusNode: focusNode,
        autofocus: autofocus,
        tooltip: tooltip,
        enableFeedback: enableFeedback,
        constraints: constraints,
      ),
      cupertino: (context, platform) => CupertinoButton(
        padding: padding,
        key: widgetKey,
        child: icon,
        onPressed: onPressed,
        color: color,
        alignment: alignment,
      ),
    );
  }
}
