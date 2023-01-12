import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PrivacyLinkWidget extends StatelessWidget {
  static const linagoraPrivacy = 'https://www.linagora.com/en/legal/privacy';

  final String privacyUrlString;

  const PrivacyLinkWidget({Key? key, this.privacyUrlString = linagoraPrivacy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context).privacyPolicy,
        style: const TextStyle(
          color: AppColor.loginTextFieldFocusedBorder,
          fontSize: 14),
        recognizer: TapGestureRecognizer()..onTap = () async {
          if (await canLaunchUrlString(privacyUrlString)) {
            launchUrlString(privacyUrlString);
          }
        }
      )
    );
  }
}
