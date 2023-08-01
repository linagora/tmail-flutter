
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_label_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerLabelWidget extends StatelessWidget {

  final String countSpamEmailsAsString;

  const SpamReportBannerLabelWidget({super.key, required this.countSpamEmailsAsString});

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          imagePaths.icInfoCircleOutline,
          width: SpamReportBannerLabelStyles.iconSize,
          height: SpamReportBannerLabelStyles.iconSize
        ),
        const SizedBox(width: SpamReportBannerLabelStyles.space),
        Text(
          AppLocalizations.of(context).countNewSpamEmails(countSpamEmailsAsString),
          style: const TextStyle(
            fontSize: SpamReportBannerLabelStyles.labelTextSize,
            color: SpamReportBannerLabelStyles.labelTextColor,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}
