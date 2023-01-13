import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SpamReportBannerWebWidget extends StatelessWidget {
  const SpamReportBannerWebWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    final _spamReportController = Get.find<SpamReportController>();
    final _imagePaths = Get.find<ImagePaths>();
    return Obx(() {
      if (_spamReportController.notShowSpamReportBanner) {
        return const SizedBox(
          height: 8,
        );
      }
      return Container(
        height: 84,
        margin: const EdgeInsets.only(right: 16, top: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
            color: AppColor.colorSpamReportBox.withOpacity(0.12)),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      _imagePaths.icInfoCircleOutline,
                      width: 28,
                      height: 28,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).countNewSpamEmails(
                        _spamReportController.numberOfUnreadSpamEmails),
                      style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32,
                  ),
                  child: buildTextButton(
                    AppLocalizations.of(context).showDetails,
                    height: 36,
                    width: 115,
                    textStyle: const TextStyle(
                        fontSize: 15,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w400),
                    backgroundColor: AppColor.colorCreateNewIdentityButton,
                    radius: 10,
                    onTap: () => _spamReportController.openMailbox(context),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: buildSVGIconButton(
                icon: _imagePaths.icCloseComposer,
                onTap: () => _spamReportController.dismissSpamReportAction(),
              ),
            ),
          ],
        ),
      );
    });
  }
}