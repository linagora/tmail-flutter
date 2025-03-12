
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/update_screen_display_mode_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/expand_composer_button.dart';

class ComposerOverlayView extends StatelessWidget {
  final ComposerManager composerManager;
  final bool isDesktopScreen;

  const ComposerOverlayView({
    super.key, 
    required this.composerManager,
    required this.isDesktopScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final composers = composerManager.composers;
      final composerIdsQueue = composerManager.composerIdsQueue;
      if (composers.isEmpty || composerIdsQueue.isEmpty) return const SizedBox.shrink();

      if (!isDesktopScreen) {
        final firstResponsiveComposerView = composerManager.firstComposerViewWhenResponsiveChanged;
        if (firstResponsiveComposerView != null) return firstResponsiveComposerView;
      }

      final fullScreenComposerView = composerManager.firstFullScreenComposerView;
      if (fullScreenComposerView != null) return fullScreenComposerView;

      if (composerIdsQueue.length == 1) {
        final composerView = composerManager.getComposerView(composerIdsQueue.first);

        return Padding(
          padding: const EdgeInsetsDirectional.all(ComposerStyle.padding),
          child: composerView.controller.isHiddenScreen
            ? ExpandComposerButton(
                countComposerHidden: 1,
                onRemoveHiddenComposerItem: (controller) =>
                  controller.handleClickCloseComposer(context),
                onShowComposerAction: composerManager.showComposerIfHidden,
              )
            : composerView,
        );
      }

      final countComposerHidden = composerManager.countComposerHidden;
      final visibleComposers = composerIdsQueue
          .map(composerManager.getComposerView)
          .where((view) => !view.controller.isHiddenScreen)
          .toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(ComposerStyle.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (countComposerHidden > 0)
                ExpandComposerButton(
                  countComposerHidden: countComposerHidden,
                  onRemoveHiddenComposerItem: (controller) =>
                      controller.handleClickCloseComposer(context),
                  onShowComposerAction: composerManager.showComposerIfHidden,
                ),
              ...visibleComposers,
            ],
          ),
        ),
      );
    });
  }
}
