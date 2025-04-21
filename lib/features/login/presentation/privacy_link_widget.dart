import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class PrivacyLinkWidget extends StatelessWidget {
  final String privacyUrlString;

  const PrivacyLinkWidget({Key? key, this.privacyUrlString = AppConfig.linagoraPrivacyUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).byContinuingYouAreAgreeingToOur,
          style: const TextStyle(
            color: AppColor.colorTextBody,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        RichText(
          text: TextSpan(
            text: AppLocalizations.of(context).privacyPolicy,
            style: const TextStyle(
              color: AppColor.loginTextFieldFocusedBorder,
              fontSize: 14),
            recognizer: TapGestureRecognizer()..onTap = () => AppUtils().launchLink(privacyUrlString)
          )
        )
      ],
    );
  }
}
