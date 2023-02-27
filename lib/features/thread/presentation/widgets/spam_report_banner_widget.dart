import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
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
        height: 124,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
            color: AppColor.colorSpamReportBox.withOpacity(0.12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    imagePaths.icInfoCircleOutline,
                    width: 28,
                    height: 28,
                    colorFilter: AppColor.primaryColor.asFilter(),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalizations.of(context).countNewSpamEmails(spamReportController.numberOfUnreadSpamEmails),
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _spamReportButtonAction(
                          context,
                          AppLocalizations.of(context).showDetails,
                          AppColor.primaryColor,
                          () => spamReportController.openMailbox(context)),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _spamReportButtonAction(
                          context,
                          AppLocalizations.of(context).dismiss,
                          AppColor.textFieldErrorBorderColor,
                          () => spamReportController
                              .dismissSpamReportAction()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _spamReportButtonAction(BuildContext context, String title, Color colorText, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.colorCreateNewIdentityButton),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15, color: colorText, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}