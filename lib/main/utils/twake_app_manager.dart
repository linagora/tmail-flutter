import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';

class TwakeAppManager {
  ComposerOverlayState? _composerOverlayState;

  void openComposerOnWeb() =>
      _composerOverlayState = ComposerOverlayState.active;

  void closeComposerOnWeb() {
    _composerOverlayState = ComposerOverlayState.inActive;
    _composerOverlayState = null;
  }

  bool get isComposerOpened =>
      _composerOverlayState == ComposerOverlayState.active;

  void dispose() {
    _composerOverlayState = null;
  }
}
