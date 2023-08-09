
import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class TMailContainerWidget extends StatelessWidget {

  final OnTapActionCallback? onTapActionCallback;
  final OnTapActionAtPositionCallback? onTapActionAtPositionCallback;

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

  const TMailContainerWidget({
    super.key,
    required this.child,
    this.onTapActionCallback,
    this.onTapActionAtPositionCallback,
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
  });

  @override
  Widget build(BuildContext context) {
    final materialChild = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapActionCallback,
        onTapDown: (detail) {
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
        },
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: tooltipMessage != null
          ? Tooltip(
              message: tooltipMessage,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColor.colorButtonHeaderThread,
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
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