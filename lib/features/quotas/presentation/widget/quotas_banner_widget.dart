import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_banner_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

class QuotasBannerWidget extends ConsumerWidget {

  final QuotasController _quotasController = Get.find<QuotasController>();

  QuotasBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceFqdn = PlatformInfo.isWeb
        ? ref.watch(workplaceFqdnProvider)
        : null;

    return Obx(() => _buildBanner(context, workplaceFqdn));
  }

  Widget _buildBanner(BuildContext context, String? workplaceFqdn) {
    final octetQuota = _quotasController
        .mailboxDashBoardController
        .octetsQuota
        .value;

    if (octetQuota == null) return const SizedBox.shrink();
    if (!_shouldDisplayBanner(octetQuota)) return const SizedBox.shrink();

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
          _buildBannerContent(context, octetQuota, workplaceFqdn),
          DefaultCloseButtonWidget(
            iconClose: _quotasController.imagePaths.icCloseDialog,
            onTapActionCallback: _quotasController.closeBanner,
          ),
        ],
      ),
    );
  }

  bool _shouldDisplayBanner(Quota octetQuota) {
    if (!octetQuota.allowedDisplayToQuotaBanner) return false;
    return _quotasController.isBannerEnabled.isTrue;
  }

  Widget _buildBannerContent(
    BuildContext context,
    Quota octetQuota,
    String? workplaceFqdn,
  ) {
    return Padding(
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
          _buildQuotaDetails(context, octetQuota, workplaceFqdn),
        ],
      ),
    );
  }

  Widget _buildQuotaDetails(
    BuildContext context,
    Quota octetQuota,
    String? workplaceFqdn,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            octetQuota.getQuotaBannerTitle(context),
            style: QuotasBannerStyles.titleTextStyle,
          ),
          const SizedBox(height: 8),
          _buildSubtitle(context, workplaceFqdn),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, String? workplaceFqdn) {
    final appLocalizations = AppLocalizations.of(context);

    if (!PlatformInfo.isWeb) {
      return _buildSubtitleWithoutPremium(appLocalizations);
    }
    if (_quotasController.isManageMyStorageDisabled(
      workplaceFqdn: workplaceFqdn,
    )) {
      return _buildSubtitleWithoutPremium(appLocalizations);
    }

    return Wrap(
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
          onTapActionCallback: () => _quotasController.handleManageMyStorage(
            workplaceFqdn: workplaceFqdn,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitleWithoutPremium(AppLocalizations appLocalizations) {
    return Text(
      appLocalizations.quotaBannerWarningSubtitleWithoutPremium,
      style: QuotasBannerStyles.subTitleTextStyle,
    );
  }
}
