import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_button_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_button_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_label_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final SpamReportController spamReportController;

  const SpamReportBannerWidget({
    Key? key,
    required this.spamReportController,
    this.margin
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Obx(() {
      if (spamReportController.spamReportState.value == SpamReportState.disabled
          || spamReportController.presentationSpamMailbox.value == null) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: margin,
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
            SpamReportBannerLabelWidget(countSpamEmailsAsString: spamReportController.numberOfUnreadSpamEmails),
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