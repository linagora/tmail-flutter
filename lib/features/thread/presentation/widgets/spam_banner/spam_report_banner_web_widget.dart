import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_button_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_label_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_web_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_button_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_label_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerWebWidget extends StatelessWidget {
  const SpamReportBannerWebWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    final spamReportController = Get.find<SpamReportController>();
    final imagePaths = Get.find<ImagePaths>();
    return Obx(() {
      if (spamReportController.spamReportState.value == SpamReportState.disabled
          || spamReportController.presentationSpamMailbox.value == null) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: SpamReportBannerWebStyles.bannerMargin,
        width: double.infinity,
        padding: SpamReportBannerWebStyles.bannerPadding,
        decoration: ShapeDecoration(
          color: SpamReportBannerWebStyles.backgroundColor,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: SpamReportBannerWebStyles.strokeBorderColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(SpamReportBannerWebStyles.borderRadius)),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SpamReportBannerLabelWidget(
                  countSpamEmailsAsString: spamReportController.numberOfUnreadSpamEmails,
                  labelColor: SpamReportBannerLabelStyles.highlightLabelTextColor
                ),
                const SizedBox(width: 32),
                SpamReportBannerButtonWidget(
                  label: AppLocalizations.of(context).showDetails,
                  labelColor: SpamReportBannerButtonStyles.positiveButtonTextColor,
                  onTap: spamReportController.openMailbox,
                  icon: DirectionUtils.isDirectionRTLByLanguage(context)
                    ? imagePaths.icArrowLeft
                    : imagePaths.icArrowRight,
                  iconLeftAlignment: false,
                  wrapContent: true,
                ),
              ],
            ),
            PositionedDirectional(
              end: 0,
              child: SpamReportBannerButtonWidget(
                label: AppLocalizations.of(context).dismiss,
                labelColor: SpamReportBannerButtonStyles.negativeButtonTextColor,
                onTap: () => spamReportController.dismissSpamReportAction(context),
                icon: imagePaths.icClose,
                wrapContent: true,
              ),
            )
          ],
        ),
      );
    });
  }
}