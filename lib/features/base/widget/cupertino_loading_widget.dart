import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/styles/cupertino_loading_widget_styles.dart';

class CupertinoLoadingWidget extends StatelessWidget {

  final double? size;

  const CupertinoLoadingWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? CupertinoLoadingWidgetStyles.size,
        height: size ?? CupertinoLoadingWidgetStyles.size,
        child: const CupertinoActivityIndicator(color: CupertinoLoadingWidgetStyles.progressColor)
      )
    );
  }
}