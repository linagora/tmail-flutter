
import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TMailButtonWidget extends StatelessWidget {

  final OnTapActionCallback? onTapActionCallback;
  final OnTapActionAtPositionCallback? onTapActionAtPositionCallback;

  final double borderRadius;
  final double? width;
  final double maxWidth;
  final double maxHeight;
  final String? tooltipMessage;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final String text;
  final String? icon;
  final bool verticalDirection;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;

  const TMailButtonWidget({
    super.key,
    required this.text,
    this.onTapActionCallback,
    this.onTapActionAtPositionCallback,
    this.borderRadius = 20,
    this.width,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.tooltipMessage,
    this.backgroundColor,
    this.padding,
    this.verticalDirection = false,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.textStyle,
  });

  factory TMailButtonWidget.fromIcon({
    required String icon,
    final Key? key,
    OnTapActionCallback? onTapActionCallback,
    OnTapActionAtPositionCallback? onTapActionAtPositionCallback,
    double borderRadius = 20,
    double? width,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    String? tooltipMessage,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    String text = '',
    bool verticalDirection = false,
    double iconSize = 24,
    Color? iconColor,
    TextStyle? textStyle,
  }) {
    return TMailButtonWidget(
      key: key,
      text: text,
      onTapActionCallback: onTapActionCallback,
      onTapActionAtPositionCallback: onTapActionAtPositionCallback,
      borderRadius: borderRadius,
      width: width,
      maxWidth : maxWidth,
      maxHeight: maxHeight,
      tooltipMessage: tooltipMessage,
      backgroundColor: backgroundColor,
      padding: padding,
      verticalDirection: verticalDirection,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;

    if (icon != null && text.isNotEmpty) {
      if (verticalDirection) {
        childWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.fill,
              colorFilter: iconColor?.asFilter()
            ),
            Text(
              text,
              style: textStyle ?? const TextStyle(
                fontSize: 12,
                color: AppColor.colorTextButtonHeaderThread
              ),
            ),
          ]
        );
      } else {
        childWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.fill,
              colorFilter: iconColor?.asFilter()
            ),
            Text(
              text,
              style: textStyle ?? const TextStyle(
                fontSize: 12,
                color: AppColor.colorTextButtonHeaderThread
              ),
            ),
          ]
        );
      }
    } else if (icon != null) {
      childWidget = SvgPicture.asset(
        icon!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.fill,
        colorFilter: iconColor?.asFilter()
      );
    } else {
      childWidget = Text(
        text,
        style: textStyle ?? const TextStyle(
          fontSize: 12,
          color: AppColor.colorTextButtonHeaderThread
        ),
      );
    }

    return TMailContainerWidget(
      onTapActionCallback: onTapActionCallback,
      onTapActionAtPositionCallback: onTapActionAtPositionCallback,
      borderRadius: borderRadius,
      width: width,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      tooltipMessage: tooltipMessage,
      backgroundColor: backgroundColor,
      padding: padding,
      child: childWidget,
    );
  }
}