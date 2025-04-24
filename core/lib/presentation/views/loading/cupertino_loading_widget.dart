import 'package:core/presentation/views/loading/cupertino_loading_widget_styles.dart';
import 'package:core/presentation/views/semantics/icon_semantics.dart';
import 'package:flutter/cupertino.dart';

class CupertinoLoadingWidget extends StatelessWidget {

  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool isCenter;
  final String? semanticLabel;

  const CupertinoLoadingWidget({
    super.key,
    this.size,
    this.padding,
    this.isCenter = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = isCenter
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

    if (semanticLabel != null) {
      item = IconSemantics(label: semanticLabel!, child: item);
    }

    if (padding != null) {
      return Padding(padding: padding!, child: item);
    } else {
      return item;
    }
  }
}