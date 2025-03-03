
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
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
        return ComposerStyle.normalWidth;
      case ScreenDisplayMode.minimize:
        return ComposerStyle.minimizeWidth;
      case ScreenDisplayMode.hidden:
      case ScreenDisplayMode.fullScreen:
        return 0;
    }
  }

  void setScreenDisplayMode(ScreenDisplayMode newDisplayMode) =>
      screenDisplayMode.value = newDisplayMode;

  void updateDisplayModeForComposerQueue(ScreenDisplayMode newDisplayMode) {
    if (composerId == null || currentContext == null) return;

    final composerManager = mailboxDashBoardController.composerManager;
    final screenWidth = responsiveUtils.getSizeScreenWidth(currentContext!);

    composerManager.arrangeComposerWhenComposerDisplayModeChanged(
      screenWidth: screenWidth,
      updatedComposerId: composerId!,
      newDisplayMode: newDisplayMode,
    );
  }
}