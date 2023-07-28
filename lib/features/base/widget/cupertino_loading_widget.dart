import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/styles/cupertino_loading_widget_styles.dart';

class CupertinoLoadingWidget extends StatelessWidget {
  const CupertinoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: CupertinoLoadingWidgetStyles.size,
        height: CupertinoLoadingWidgetStyles.size,
        child: CupertinoActivityIndicator(color: CupertinoLoadingWidgetStyles.progressColor)
      )
    );
  }
}