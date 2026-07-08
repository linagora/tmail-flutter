import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';

/// App-lifetime [UrgentExceptionHandler], decoupled from any screen controller.
///
/// Bound permanently at bootstrap (`MainBindings`) so Riverpod flows and
/// delegates can route urgent exceptions on any screen — including where
/// `MailboxDashBoardController` is absent (e.g. a Settings web-reload). Reuses
/// the `BaseController` routing unchanged; owns no view. See ADR-0093.
class UrgentExceptionHandlerService extends BaseController {
  @override
  void onReady() {
    // No super call: this service has no view, so it must not register the
    // browser-unload listeners the base sets up — those belong to the screen.
  }
}
