import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/validate_premium_storage_extension.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin ExpandFolderTriggerScrollableMixin {
  void triggerScrollWhenExpandFolder(
    ExpandMode expandMode,
    GlobalKey itemKey,
    ScrollController scrollController,
  ) {
    if (expandMode == ExpandMode.COLLAPSE) return;

    final context = itemKey.currentContext;
    if (context == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelfIfNeeded(context, scrollController);
    });
  }

  void _scrollToSelfIfNeeded(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final offsetY = _getOffsetY();
    final bottomY = position.dy + renderBox.size.height + offsetY;
    log('$runtimeType::_scrollToSelfIfNeeded:position = $position |screenHeight = $screenHeight | bottomY = $bottomY | offsetY = $offsetY');
    if (bottomY > screenHeight) {
      final scrollOffset =
          scrollController.offset + bottomY - screenHeight + 40;
      log('$runtimeType::_scrollToSelfIfNeeded:scrollOffset = $scrollOffset:');
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double _getOffsetY() {
    try {
      final quota = getBinding<MailboxDashBoardController>()?.octetsQuota.value;
      final isQuotaViewDisplayed = quota?.storageAvailable ?? false;

      final isPremiumAvailable = getBinding<MailboxDashBoardController>()
          ?.validatePremiumIsAvailable() ?? false;
      final isIncreaseSpaceButtonDisplayed =
          isPremiumAvailable && PlatformInfo.isWeb;

      if (isQuotaViewDisplayed && isIncreaseSpaceButtonDisplayed) return 260;
      if (isQuotaViewDisplayed) return 200;
      if (isIncreaseSpaceButtonDisplayed) return 150;
      return 70;
    } catch (_) {
      return 70;
    }
  }
}
