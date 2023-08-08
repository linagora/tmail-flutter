
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
  final String? tooltipMessage;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const TMailContainerWidget({
    super.key,
    required this.child,
    this.onTapActionCallback,
    this.onTapActionAtPositionCallback,
    this.borderRadius = 20,
    this.width,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.tooltipMessage,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColor.colorButtonHeaderThread,
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                ),
                width: width,
                constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
                padding: padding ?? const EdgeInsetsDirectional.all(8),
                child: child
              )
            )
          : Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColor.colorButtonHeaderThread,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              width: width,
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
              padding: padding ?? const EdgeInsetsDirectional.all(8),
              child: child
            )
      ),
    );
  }
}