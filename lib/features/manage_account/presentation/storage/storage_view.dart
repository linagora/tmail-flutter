import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/storage_progress_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/upgrade_storage_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart';
import 'package:tmail_ui_user/features/paywall/presentation/extensions/premium_cta_ref_extension.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';

class StorageView extends StatelessWidget with AppLoaderMixin {
  const StorageView({Key? key}) : super(key: key);

  ImagePaths get imagePaths => Get.find<ImagePaths>();

  ManageAccountDashBoardController get dashBoardController =>
      Get.find<ManageAccountDashBoardController>();

  @override
  Widget build(BuildContext context) {
    final viewContext = _StorageViewContext(
      context: context,
      responsiveUtils: Get.find<ResponsiveUtils>(),
    );

    return SettingDetailViewBuilder(
      responsiveUtils: viewContext.responsiveUtils,
      child: _buildStorageBody(viewContext),
    );
  }

  Widget _buildStorageBody(_StorageViewContext viewContext) {
    return Container(
      color: SettingsUtils.getContentBackgroundColor(
        viewContext.context,
        viewContext.responsiveUtils,
      ),
      decoration: SettingsUtils.getBoxDecorationForContent(
        viewContext.context,
        viewContext.responsiveUtils,
      ),
      width: double.infinity,
      padding: viewContext.isDesktop
          ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStorageHeader(viewContext),
          Expanded(
            child: _buildStorageContent(viewContext),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageHeader(_StorageViewContext viewContext) {
    if (viewContext.isWebDesktop) {
      return SettingHeaderWidget(
        menuItem: AccountMenuItem.storage,
        textStyle: ThemeUtils.textStyleInter600().copyWith(
          color: Colors.black.withValues(alpha: 0.9),
        ),
        padding: EdgeInsets.zero,
      );
    }

    return const SettingExplanationWidget(
      menuItem: AccountMenuItem.storage,
      padding: EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        bottom: 16,
      ),
      isCenter: true,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStorageContent(_StorageViewContext viewContext) {
    return Obx(() {
      final octetsQuota = dashBoardController.octetsQuota.value;
      if (octetsQuota == null || !octetsQuota.storageAvailable) {
        return const SizedBox.shrink();
      }

      return _buildQuotaContent(
        octetsQuota: octetsQuota,
        viewContext: viewContext,
      );
    });
  }

  Widget _buildQuotaContent({
    required Quota octetsQuota,
    required _StorageViewContext viewContext,
  }) {
    final premiumContext =
        dashBoardController.currentPremiumCtaContext;
    return Consumer(
      builder: (context, ref, _) {
        final premiumState = ref.watchWebPremiumCta(premiumContext);
        final upgradeStorageWidget = _buildUpgradeStorageWidget(
          octetsQuota: octetsQuota,
          viewContext: viewContext,
          premiumState: premiumState,
          ref: ref,
        );
        final children = <Widget>[
          StorageProgressBarWidget(
            imagePaths: imagePaths,
            quota: octetsQuota,
            isMobile: viewContext.isMobile,
          ),
          if (upgradeStorageWidget != null) upgradeStorageWidget,
        ];

        return SingleChildScrollView(
          child: Padding(
            padding: _getPadding(viewContext),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        );
      },
    );
  }

  Widget? _buildUpgradeStorageWidget({
    required Quota octetsQuota,
    required _StorageViewContext viewContext,
    required PremiumCtaState premiumState,
    required WidgetRef ref,
  }) {
    final isPremiumAvailable = premiumState is PremiumCtaAvailable;
    final isQuotaExceeds90Percent = octetsQuota.allowedDisplayToQuotaBanner;
    if (!isPremiumAvailable && !isQuotaExceeds90Percent) return null;

    return UpgradeStorageWidget(
      imagePaths: imagePaths,
      isMobile: viewContext.isMobile,
      isPremiumAvailable: isPremiumAvailable,
      isQuotaExceeds90Percent: isQuotaExceeds90Percent,
      onUpgradeStorageAction: () => ref.openPremiumCta(
        dashBoardController.currentPremiumCtaContext,
      ),
    );
  }

  EdgeInsetsGeometry _getPadding(_StorageViewContext viewContext) {
    if (viewContext.isMobile) {
      return const EdgeInsetsDirectional.only(top: 31, start: 24, end: 24);
    } else if (viewContext.isDesktop) {
      return const EdgeInsetsDirectional.only(top: 37, start: 15);
    } else {
      return const EdgeInsetsDirectional.only(top: 31, start: 32, end: 32);
    }
  }
}

class _StorageViewContext {
  final BuildContext context;
  final ResponsiveUtils responsiveUtils;
  final bool isMobile;
  final bool isDesktop;
  final bool isWebDesktop;

  _StorageViewContext({
    required this.context,
    required this.responsiveUtils,
  }) : isMobile = responsiveUtils.isMobile(context),
       isDesktop = responsiveUtils.isDesktop(context),
       isWebDesktop = responsiveUtils.isWebDesktop(context);
}
