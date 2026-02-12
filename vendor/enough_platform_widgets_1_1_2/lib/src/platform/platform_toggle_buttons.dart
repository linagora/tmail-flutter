import 'package:enough_platform_widgets/src/cupertino/cupertino_multiple_segmented.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Provides a platform aware `ToggleButtons` replacement
class PlatformToggleButtons extends StatelessWidget {
  final Key? widgetKey;
  final List<Widget> children;
  final List<bool> isSelected;
  final void Function(int)? onPressed;
  final MouseCursor? mouseCursor;
  final TextStyle? textStyle;
  final BoxConstraints? constraints;
  final Color? color;
  final Color? selectedColor;
  final Color? disabledColor;
  final Color? fillColor;
  final Color? focusColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? splashColor;
  final List<FocusNode>? focusNodes;
  final bool renderBorder;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? disabledBorderColor;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Axis direction;
  final VerticalDirection verticalDirection;
  final EdgeInsets? cupertinoPadding;

  const PlatformToggleButtons({
    Key? key,
    this.widgetKey,
    required this.children,
    required this.isSelected,
    this.onPressed,
    this.mouseCursor,
    this.textStyle,
    this.constraints,
    this.color,
    this.selectedColor,
    this.disabledColor,
    this.fillColor,
    this.focusColor,
    this.highlightColor,
    this.hoverColor,
    this.splashColor,
    this.focusNodes,
    this.renderBorder = true,
    this.borderColor,
    this.selectedBorderColor,
    this.disabledBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.direction = Axis.horizontal,
    this.verticalDirection = VerticalDirection.down,
    this.cupertinoPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => ToggleButtons(
        key: widgetKey,
        children: children,
        isSelected: isSelected,
        onPressed: onPressed,
        mouseCursor: mouseCursor,
        textStyle: textStyle,
        constraints: constraints,
        color: color,
        selectedColor: selectedColor,
        disabledColor: disabledColor,
        fillColor: fillColor,
        focusColor: focusColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
        splashColor: splashColor,
        focusNodes: focusNodes,
        renderBorder: renderBorder,
        borderColor: borderColor,
        selectedBorderColor: selectedBorderColor,
        disabledBorderColor: disabledBorderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        direction: direction,
        verticalDirection: verticalDirection,
      ),
      cupertino: (context, platform) => CupertinoMultipleSegmentedControl(
        children: children,
        isSelected: isSelected,
        onPressed: onPressed,
        unselectedColor: color,
        selectedColor: fillColor,
        borderColor: borderColor,
        pressedColor: splashColor,
        padding: cupertinoPadding,
      ),
    );
  }
}
