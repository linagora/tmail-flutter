import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_button_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerWidget extends StatelessWidget {
  const SpamReportBannerWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    final spamReportController = Get.find<SpamReportController>();
    final imagePaths = Get.find<ImagePaths>();
    
    return Obx(() {
      if (!spamReportController.enableSpamReport || spamReportController.notShowSpamReportBanner) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsetsDirectional.only(
          start: SpamReportBannerStyles.horizontalMargin,
          end: SpamReportBannerStyles.horizontalMargin,
          bottom: SpamReportBannerStyles.verticalMargin
        ),
        padding: const EdgeInsetsDirectional.all(SpamReportBannerStyles.padding),
        decoration: ShapeDecoration(
          color: SpamReportBannerStyles.backgroundColor,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: SpamReportBannerStyles.strokeBorderColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(SpamReportBannerStyles.borderRadius)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  imagePaths.icInfoCircleOutline,
                  width: SpamReportBannerStyles.iconSize,
                  height: SpamReportBannerStyles.iconSize
                ),
                const SizedBox(width: SpamReportBannerStyles.space),
                Text(
                  AppLocalizations.of(context).countNewSpamEmails(spamReportController.numberOfUnreadSpamEmails),
                  style: const TextStyle(
                    fontSize: SpamReportBannerStyles.labelTextSize,
                    color: SpamReportBannerStyles.labelTextColor,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpamReportBannerStyles.space),
            Row(
              children: [
                Expanded(
                  child: SpamReportBannerButtonWidget(
                    label: AppLocalizations.of(context).showDetails,
                    labelColor: SpamReportBannerButtonStyles.positiveButtonTextColor,
                    onTap: spamReportController.openMailbox
                  ),
                ),
                const SizedBox(width: SpamReportBannerStyles.space),
                Expanded(
                  child: SpamReportBannerButtonWidget(
                    label: AppLocalizations.of(context).dismiss,
                    labelColor: SpamReportBannerButtonStyles.negativeButtonTextColor,
                    onTap: () => spamReportController.dismissSpamReportAction(context)
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}