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
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? CircleLoadingWidgetStyles.size;
    final loadingStrokeWidth = strokeWidth ?? CircleLoadingWidgetStyles.width;

    return Container(
      padding: padding,
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        color: CircleLoadingWidgetStyles.progressColor,
        strokeWidth: loadingStrokeWidth,
      )
    );
  }
}