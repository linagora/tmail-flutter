import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/styles/circle_loading_widget_styles.dart';

class CircleLoadingWidget extends StatelessWidget {

  final double? size;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onCancel;

  const CircleLoadingWidget({
    super.key,
    this.size,
    this.padding,
    this.strokeWidth,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? CircleLoadingWidgetStyles.size;
    final loadingStrokeWidth = strokeWidth ?? CircleLoadingWidgetStyles.width;

    return Container(
      padding: padding,
      width: loadingSize,
      height: loadingSize,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CircularProgressIndicator(
            color: CircleLoadingWidgetStyles.progressColor,
            strokeWidth: loadingStrokeWidth,
          ),
          if (onCancel != null)
            Center(
              child: TMailButtonWidget.fromIcon(
                icon: ImagePaths().icClose,
                width: loadingSize - loadingStrokeWidth,
                padding: const EdgeInsets.all(2),
                onTapActionCallback: onCancel,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      )
    );
  }
}