import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// A sign-in starts the Android and iOS app on `mine` (ADR-0114), also when the last session ended without a recorded sign-out.
Future<void> forgetLastShownAccountOnSignIn(Session session) async {
  if (!PlatformInfo.isMobile) return;
  try {
    await getBinding<LastShownAccountStore>()?.remove(session.username);
  } catch (e) {
    logWarning('forgetLastShownAccountOnSignIn: $e');
  }
}
