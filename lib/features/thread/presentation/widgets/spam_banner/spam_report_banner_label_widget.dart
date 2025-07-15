
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_label_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerLabelWidget extends StatelessWidget {

  final String countSpamEmailsAsString;
  final Color labelColor;

  const SpamReportBannerLabelWidget({
    super.key,
    required this.countSpamEmailsAsString,
    this.labelColor = SpamReportBannerLabelStyles.labelTextColor
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
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
        if (responsiveUtils.isWebDesktop(context))
          Text(
            AppLocalizations.of(context).countNewSpamEmails(countSpamEmailsAsString),
            textAlign: TextAlign.center,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: SpamReportBannerLabelStyles.labelTextSize,
              color: labelColor,
              fontWeight: FontWeight.w500
            ),
          )
        else
          Flexible(
            child: Text(
              AppLocalizations.of(context).countNewSpamEmails(countSpamEmailsAsString),
              textAlign: TextAlign.center,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: SpamReportBannerLabelStyles.labelTextSize,
                color: labelColor,
                fontWeight: FontWeight.w500
              ),
            ),
          )
      ],
    );
  }
}
