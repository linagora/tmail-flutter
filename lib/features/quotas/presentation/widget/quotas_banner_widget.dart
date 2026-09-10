import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/paywall/presentation/extensions/premium_cta_ref_extension.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_banner_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasBannerWidget extends StatelessWidget {

  final QuotasController _quotasController = Get.find<QuotasController>();

  QuotasBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Every observable the banner depends on must be read here: Obx only
    // tracks reads made synchronously inside its own builder, so a read from
    // the Consumer builder below would never trigger a rebuild.
    return Obx(() {
      final dashboardController = _quotasController.mailboxDashBoardController;
      final octetQuota = dashboardController.octetsQuota.value;
      if (octetQuota == null || !_shouldDisplayBanner(octetQuota)) {
        return const SizedBox.shrink();
      }

      final premiumContext = dashboardController.currentPremiumCtaContext;
      return Consumer(
        builder: (context, ref, _) => _buildBanner(
          context,
          octetQuota,
          ref.watchWebPremiumCta(premiumContext),
          ref,
        ),
      );
    });
  }

  Widget _buildBanner(
    BuildContext context,
    Quota octetQuota,
    PremiumCtaState premiumState,
    WidgetRef ref,
  ) {
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
          _buildBannerContent(
            context,
            octetQuota,
            premiumState,
            ref,
          ),
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
    PremiumCtaState premiumState,
    WidgetRef ref,
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
          _buildQuotaDetails(
            context,
            octetQuota,
            premiumState,
            ref,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaDetails(
    BuildContext context,
    Quota octetQuota,
    PremiumCtaState premiumState,
    WidgetRef ref,
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
          _buildSubtitle(
            context,
            premiumState,
            ref,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    PremiumCtaState premiumState,
    WidgetRef ref,
  ) {
    final appLocalizations = AppLocalizations.of(context);

    if (premiumState is! PremiumCtaAvailable) {
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
          onTapActionCallback: () => ref.openPremiumCta(
            _quotasController
                .mailboxDashBoardController
                .currentPremiumCtaContext,
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
