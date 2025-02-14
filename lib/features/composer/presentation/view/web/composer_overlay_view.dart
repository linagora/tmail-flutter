
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/update_screen_display_mode_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/expand_composer_button.dart';

class ComposerOverlayView extends StatefulWidget {
  const ComposerOverlayView({super.key});

  @override
  State<ComposerOverlayView> createState() => _ComposerOverlayViewState();
}

class _ComposerOverlayViewState extends State<ComposerOverlayView> {
  late final ComposerManager _composerManager;
  late final ResponsiveUtils _responsiveUtils;

  @override
  void initState() {
    super.initState();
    _composerManager = Get.find<ComposerManager>();
    _responsiveUtils = Get.find<ResponsiveUtils>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final composers = _composerManager.composers;
      final composerIdsQueue = _composerManager.composerIdsQueue;
      if (composers.isEmpty || composerIdsQueue.isEmpty) return const SizedBox.shrink();

      if (!_responsiveUtils.isDesktop(context)) {
        final firstResponsiveComposerView = _composerManager.firstComposerViewWhenResponsiveChanged;
        if (firstResponsiveComposerView != null) return firstResponsiveComposerView;
      }

      final fullScreenComposerView = _composerManager.firstFullScreenComposerView;
      if (fullScreenComposerView != null) return fullScreenComposerView;

      if (composerIdsQueue.length == 1) {
        return _composerManager.getComposerView(composerIdsQueue.first);
      }

      final isExceedsScreenSize = _composerManager.isExceedsScreenSize(
        screenWidth: context.width,
      );

      if (isExceedsScreenSize) {
        _composerManager.syncComposerQueue(screenWidth: context.width);
      }

      final countComposerHidden = _composerManager.countComposerHidden;
      final visibleComposers = composerIdsQueue
          .map(_composerManager.getComposerView)
          .where((view) => !view.controller.isHiddenScreen)
          .toList();

      return Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(ComposerUtils.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (countComposerHidden > 0)
                ExpandComposerButton(
                  countComposerHidden: countComposerHidden,
                  onRemoveHiddenComposerItem: (controller) =>
                      controller.handleClickCloseComposer(context),
                  onShowComposerAction: _composerManager.showComposerIfHidden,
                ),
              ...visibleComposers,
            ],
          ),
        ),
      );
    });
  }
}
