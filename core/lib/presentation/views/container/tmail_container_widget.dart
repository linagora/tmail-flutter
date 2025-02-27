
import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class TMailContainerWidget extends StatelessWidget {

  final OnTapActionCallback? onTapActionCallback;
  final OnTapActionAtPositionCallback? onTapActionAtPositionCallback;
  final OnLongPressActionCallback? onLongPressActionCallback;

  final Widget child;
  final double borderRadius;
  final double? width;
  final double maxWidth;
  final double maxHeight;
  final double minWidth;
  final String? tooltipMessage;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final Color? hoverColor;

  const TMailContainerWidget({
    super.key,
    required this.child,
    this.onTapActionCallback,
    this.onTapActionAtPositionCallback,
    this.onLongPressActionCallback,
    this.borderRadius = 20,
    this.width,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.minWidth = 0,
    this.tooltipMessage,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
    this.margin,
    this.border,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialChild = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTapActionCallback,
        excludeFromSemantics: true,
        onTapDown: onTapActionAtPositionCallback != null
          ? (detail) {
              if (onTapActionAtPositionCallback != null) {
                final screenSize = MediaQuery.of(context).size;
                final offset = detail.globalPosition;
                final position = RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  screenSize.width - offset.dx,
                  screenSize.height - offset.dy,
                );
                onTapActionAtPositionCallback!.call(position);
              }
            }
          : null,
        hoverColor: hoverColor,
        onLongPress: onLongPressActionCallback,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: tooltipMessage != null
          ? Tooltip(
              message: tooltipMessage,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColor.colorButtonHeaderThread,
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  border: border,
                  boxShadow: boxShadow
                ),
                width: width,
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  minWidth: minWidth
                ),
                padding: padding ?? const EdgeInsetsDirectional.all(8),
                child: child
              )
            )
          : Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColor.colorButtonHeaderThread,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                border: border,
                boxShadow: boxShadow
              ),
              width: width,
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                minWidth: minWidth
              ),
              padding: padding ?? const EdgeInsetsDirectional.all(8),
              child: child
            )
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: materialChild);
    } else {
      return materialChild;
    }
  }
}