import 'package:core/presentation/views/loading/cupertino_loading_widget_styles.dart';
import 'package:flutter/cupertino.dart';

class CupertinoLoadingWidget extends StatelessWidget {

  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool isCenter;

  const CupertinoLoadingWidget({
    super.key,
    this.size,
    this.padding,
    this.isCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    final item = isCenter
      ? Center(
          child: SizedBox(
            width: size ?? CupertinoLoadingWidgetStyles.size,
            height: size ?? CupertinoLoadingWidgetStyles.size,
            child: const CupertinoActivityIndicator(
              color: CupertinoLoadingWidgetStyles.progressColor
            )
          )
        )
      : Align(
          alignment: AlignmentDirectional.topCenter,
          child: SizedBox(
            width: size ?? CupertinoLoadingWidgetStyles.size,
            height: size ?? CupertinoLoadingWidgetStyles.size,
            child: const CupertinoActivityIndicator(
              color: CupertinoLoadingWidgetStyles.progressColor
            )
          ),
        );
    if (padding != null) {
      return Padding(padding: padding!, child: item);
    } else {
      return item;
    }
  }
}