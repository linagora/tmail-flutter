import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HyperLinkWidget extends StatelessWidget {

  final String urlString;

  const HyperLinkWidget({Key? key, required this.urlString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: urlString,
        style: const TextStyle(
          color: AppColor.primaryColor,
          fontSize: 16,
          decoration: TextDecoration.underline
        ),
        recognizer: TapGestureRecognizer()..onTap = () async {
          if (await canLaunchUrlString(urlString)) {
            launchUrlString(
              urlString,
              mode: LaunchMode.externalApplication
            );
          }
        }
      )
    );
  }
}
