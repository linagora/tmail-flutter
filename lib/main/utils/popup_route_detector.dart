import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

/// Utility class for detecting popup routes with valid session handoff.
/// Extracted for testability.
class PopupRouteDetector {
  /// Session handoff validity duration in milliseconds.
  /// Session data older than this is considered stale.
  static const int sessionValidityMs = 30000; // 30 seconds

  /// localStorage key for session handoff data.
  static const String sessionStorageKey = 'tmail_popup_session';

  /// Detects if the current URL is a popup route with valid session handoff.
  /// Returns the popup route (e.g., '/popup/abc123') if valid, null otherwise.
  ///
  /// This allows popup windows to bypass the full authentication flow
  /// when opened from the main window with a valid session handoff.
  static String? detectPopupRouteWithSession() {
    if (!PlatformInfo.isWeb) return null;

    try {
      final currentUrl = html.window.location.href;
      return detectFromUrlAndStorage(
        currentUrl: currentUrl,
        getSessionData: () => html.window.localStorage[sessionStorageKey],
        getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Any error means we fall back to normal flow
      return null;
    }
  }

  /// Testable version that accepts dependencies.
  ///
  /// [currentUrl] - The current browser URL
  /// [getSessionData] - Function to retrieve session data from storage
  /// [getCurrentTimestamp] - Function to get current timestamp (for testing)
  static String? detectFromUrlAndStorage({
    required String currentUrl,
    required String? Function() getSessionData,
    required int Function() getCurrentTimestamp,
  }) {
    // Check if URL contains popup route pattern
    final emailId = extractEmailIdFromUrl(currentUrl);
    if (emailId == null) return null;

    // Check if there's valid session handoff data
    final sessionDataStr = getSessionData();
    if (!isValidSessionHandoff(
      sessionDataStr: sessionDataStr,
      getCurrentTimestamp: getCurrentTimestamp,
    )) {
      return null;
    }

    // Valid popup route with session - return the route
    return '/popup/$emailId';
  }

  /// Extracts email ID from popup URL pattern.
  /// Returns null if URL doesn't match popup route pattern.
  static String? extractEmailIdFromUrl(String url) {
    final popupMatch = RegExp(r'/popup/([^/?#]+)').firstMatch(url);
    if (popupMatch == null) return null;

    final emailId = popupMatch.group(1);
    if (emailId == null || emailId.isEmpty) return null;

    return emailId;
  }

  /// Validates session handoff data.
  /// Returns true if session data exists and is not stale.
  static bool isValidSessionHandoff({
    required String? sessionDataStr,
    required int Function() getCurrentTimestamp,
  }) {
    if (sessionDataStr == null || sessionDataStr.isEmpty) return false;

    try {
      final data = jsonDecode(sessionDataStr) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int?;
      if (timestamp == null) return false;

      final age = getCurrentTimestamp() - timestamp;
      return age <= sessionValidityMs;
    } catch (e) {
      return false;
    }
  }
}
