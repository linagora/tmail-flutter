
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_button_styles.dart';

class SpamReportBannerButtonWidget extends StatelessWidget {

  final String label;
  final Color labelColor;
  final VoidCallback onTap;

  const SpamReportBannerButtonWidget({
    super.key,
    required this.label,
    required this.labelColor,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(SpamReportBannerButtonStyles.borderRadius)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(SpamReportBannerButtonStyles.padding),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(SpamReportBannerButtonStyles.borderRadius)),
            color: SpamReportBannerButtonStyles.backgroundColor
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SpamReportBannerButtonStyles.labelTextSize,
              color: labelColor,
              fontWeight: FontWeight.w400
            ),
          ),
        ),
      ),
    );
  }
}
