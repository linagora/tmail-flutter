import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/styles/circle_loading_widget_styles.dart';

class CircleLoadingWidget extends StatelessWidget {

  final double? size;
  final double? strokeWidth;
  final EdgeInsetsGeometry? margin;

  const CircleLoadingWidget({
    super.key,
    this.size,
    this.margin,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? CircleLoadingWidgetStyles.size;
    final loadingStrokeWidth = strokeWidth ?? CircleLoadingWidgetStyles.width;

    return Container(
      margin: margin,
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        color: CircleLoadingWidgetStyles.progressColor,
        strokeWidth: loadingStrokeWidth,
      )
    );
  }
}