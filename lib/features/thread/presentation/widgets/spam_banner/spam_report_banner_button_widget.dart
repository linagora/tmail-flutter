
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_button_styles.dart';

class SpamReportBannerButtonWidget extends StatelessWidget {

  final String label;
  final Color labelColor;
  final VoidCallback onTap;
  final String? icon;
  final bool iconLeftAlignment;
  final bool wrapContent;

  const SpamReportBannerButtonWidget({
    super.key,
    required this.label,
    required this.labelColor,
    required this.onTap,
    this.icon,
    this.iconLeftAlignment = true,
    this.wrapContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(SpamReportBannerButtonStyles.borderRadius)),
        child: Container(
          width: wrapContent ? null : double.infinity,
          padding: const EdgeInsetsDirectional.all(SpamReportBannerButtonStyles.padding),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(SpamReportBannerButtonStyles.borderRadius)),
            color: SpamReportBannerButtonStyles.backgroundColor
          ),
          child: icon == null
            ? Text(
                label,
                textAlign: TextAlign.center,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: SpamReportBannerButtonStyles.labelTextSize,
                  color: labelColor,
                  fontWeight: FontWeight.w400
                )
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconLeftAlignment)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: SpamReportBannerButtonStyles.paddingIcon),
                      child: SvgPicture.asset(
                        icon!,
                        width: SpamReportBannerButtonStyles.iconSize,
                        height: SpamReportBannerButtonStyles.iconSize,
                        colorFilter: labelColor.asFilter(),
                      ),
                    ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: SpamReportBannerButtonStyles.labelTextSize,
                      color: labelColor,
                      fontWeight: FontWeight.w400
                    )
                  ),
                  if (!iconLeftAlignment)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: SpamReportBannerButtonStyles.paddingIcon),
                      child: SvgPicture.asset(
                        icon!,
                        width: SpamReportBannerButtonStyles.iconSize,
                        height: SpamReportBannerButtonStyles.iconSize,
                        colorFilter: labelColor.asFilter(),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
