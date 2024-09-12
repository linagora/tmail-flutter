import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/recover_deleted_message_loading_banner_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RecoverDeletedMessageLoadingBannerWidget extends StatelessWidget {
  final bool isLoading;
  final Widget horizontalLoadingWidget;
  final ResponsiveUtils responsiveUtils;

  const RecoverDeletedMessageLoadingBannerWidget({
    super.key,
    required this.isLoading,
    required this.horizontalLoadingWidget,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: RecoverDeletedMessageLoadingBannerStyle.getBannerMargin(
          context,
          responsiveUtils),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: AppColor.colorBorderBodyThread,
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).bannerProgressingRecoveryMessage,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            horizontalLoadingWidget
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}