import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_banner_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasBannerWidget extends StatelessWidget {

  final QuotasController _quotasController = Get.find<QuotasController>();

  QuotasBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final octetQuota = _quotasController
          .mailboxDashBoardController
          .octetsQuota
          .value;

      if (octetQuota != null &&
          octetQuota.allowedDisplayToQuotaBanner &&
          _quotasController.isBannerEnabled.isTrue) {
        final appLocalizations = AppLocalizations.of(context);

        return Container(
          decoration: const BoxDecoration(
            color: QuotasBannerStyles.backgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(QuotasBannerStyles.borderRadius),
            ),
          ),
          margin: QuotasBannerStyles.getBannerMargin(
            context,
            _quotasController.responsiveUtils,
          ),
          child: Stack(
            children: [
              Padding(
                padding: QuotasBannerStyles.bannerPadding,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _quotasController.imagePaths.icCloud,
                      width: QuotasBannerStyles.iconSize,
                      height: QuotasBannerStyles.iconSize,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: QuotasBannerStyles.iconPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            octetQuota.getQuotaBannerTitle(context),
                            style: QuotasBannerStyles.titleTextStyle,
                          ),
                          const SizedBox(height: 8),
                          if (!PlatformInfo.isWeb ||
                              _quotasController.isManageMyStorageIsDisabled)
                            Text(
                              appLocalizations.quotaBannerWarningSubtitleWithoutPremium,
                              style: QuotasBannerStyles.subTitleTextStyle,
                            )
                          else
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${appLocalizations.quotaBannerWarningSubtitleWithPremium} ',
                                  style: QuotasBannerStyles.subTitleTextStyle,
                                ),
                                TMailButtonWidget.fromText(
                                  text: appLocalizations.manageMyStorage,
                                  backgroundColor: QuotasBannerStyles.backgroundColor,
                                  textStyle: QuotasBannerStyles.manageStorageButtonTextStyle,
                                  padding: EdgeInsets.zero,
                                  onTapActionCallback:
                                    _quotasController.handleManageMyStorage,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DefaultCloseButtonWidget(
                iconClose: _quotasController.imagePaths.icCloseDialog,
                onTapActionCallback: _quotasController.closeBanner,
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
