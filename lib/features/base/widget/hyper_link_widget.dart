import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/base/styles/hyper_link_widget_styles.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class HyperLinkWidget extends StatelessWidget {

  final String urlString;

  const HyperLinkWidget({Key? key, required this.urlString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: urlString,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          color: HyperLinkWidgetStyles.textColor,
          fontSize: HyperLinkWidgetStyles.textSize,
          decoration: TextDecoration.underline
        ),
        recognizer: TapGestureRecognizer()..onTap = () => AppUtils.launchLink(urlString)
      )
    );
  }
}
