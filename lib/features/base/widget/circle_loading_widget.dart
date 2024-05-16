import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/styles/circle_loading_widget_styles.dart';

class CircleLoadingWidget extends StatelessWidget {

  final double? size;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;

  const CircleLoadingWidget({
    super.key,
    this.size,
    this.padding,
    this.strokeWidth
  });

  @override
  Widget build(BuildContext context) {
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: SizedBox(
          width: size ?? CircleLoadingWidgetStyles.size,
          height: size ?? CircleLoadingWidgetStyles.size,
          child: CircularProgressIndicator(
            color: CircleLoadingWidgetStyles.progressColor,
            strokeWidth: strokeWidth ?? CircleLoadingWidgetStyles.width,
          )
        ),
      );
    } else {
      return SizedBox(
        width: size ?? CircleLoadingWidgetStyles.size,
        height: size ?? CircleLoadingWidgetStyles.size,
        child: CircularProgressIndicator(
          color: CircleLoadingWidgetStyles.progressColor,
          strokeWidth: strokeWidth ?? CircleLoadingWidgetStyles.width,
        )
      );
    }
  }
}