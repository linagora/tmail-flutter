
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension UpdateScreenDisplayModeExtension on ComposerController {

  bool get isNormalScreen =>
      screenDisplayMode.value == ScreenDisplayMode.normal;

  bool get isMinimizeScreen =>
      screenDisplayMode.value == ScreenDisplayMode.minimize;

  bool get isHiddenScreen =>
      screenDisplayMode.value == ScreenDisplayMode.hidden;

  bool get isFullScreen =>
      screenDisplayMode.value == ScreenDisplayMode.fullScreen;

  double get composerWidth {
    switch (screenDisplayMode.value) {
      case ScreenDisplayMode.normal:
        return ComposerUtils.normalWidth;
      case ScreenDisplayMode.minimize:
        return ComposerUtils.minimizeWidth;
      case ScreenDisplayMode.hidden:
      case ScreenDisplayMode.fullScreen:
        return 0;
    }
  }

  void setScreenDisplayMode(ScreenDisplayMode displayMode) =>
      screenDisplayMode.value = displayMode;

  bool setToMinimizeIfNormal() {
    if (isNormalScreen) {
      screenDisplayMode.value = ScreenDisplayMode.minimize;
      return true;
    }
    return false;
  }

  void updateDisplayModeForComposerQueue(ScreenDisplayMode displayMode) {
    if (composerId == null || currentContext == null) return;

    final composerManager = mailboxDashBoardController.composerManager;
    final screenWidth = responsiveUtils.getSizeScreenWidth(currentContext!);

    if (!composerManager.isExceedsScreenSize(screenWidth: screenWidth)) {
      return;
    }

    if (displayMode == ScreenDisplayMode.normal) {
      final recordComposerIds = composerManager.findSurroundingComposerIds(composerId!);
      final nextComposer = recordComposerIds.nextTargetId;
      final prevComposer = recordComposerIds.previousTargetId;

      if (nextComposer != null && composerManager.getComposerView(nextComposer).controller.setToMinimizeIfNormal()) {
        return;
      }
      if (prevComposer != null && composerManager.getComposerView(prevComposer).controller.setToMinimizeIfNormal()) {
        return;
      }

      final firstNormalComposerId = composerManager.findFirstNormalComposerIdInQueue();
      if (firstNormalComposerId != null && firstNormalComposerId != composerId) {
        composerManager
          .getComposerView(firstNormalComposerId)
          .controller
          .setScreenDisplayMode(ScreenDisplayMode.minimize);
      }
    } else if (displayMode == ScreenDisplayMode.fullScreen) {

    }

    composerManager.syncComposerQueue(screenWidth: screenWidth);
  }
}