import 'dart:io';

import 'package:core/utils/app_logger.dart';

/// Calls the backend reset server running on the CI host.
///
/// The Android emulator reaches the host at 10.0.2.2. The reset server
/// (scripts/backend-reset-server.py) stops the running tmail-backend
/// container and starts a fresh one from the provisioned snapshot, then
/// returns 200 once James reports "server started".
///
/// Only active when RESET_SERVER_URL is provided via --dart-define,
/// so local runs without the reset server are unaffected.
class BackendResetClient {
  static const String _resetUrl = String.fromEnvironment(
    'RESET_SERVER_URL',
    defaultValue: '',
  );

  static bool get isEnabled => _resetUrl.isNotEmpty;

  /// Sends POST /reset and waits for the backend to confirm readiness.
  /// Times out after [timeout] (default 3 minutes to allow container restart).
  static Future<void> reset({
    Duration timeout = const Duration(minutes: 3),
  }) async {
    if (!isEnabled) return;

    final uri = Uri.parse('$_resetUrl/reset');
    final client = HttpClient()..connectionTimeout = timeout;

    try {
      final request = await client.postUrl(uri);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        throw Exception('Backend reset failed with status ${response.statusCode}');
      }
    } catch (e) {
      logWarning('Backend reset failed: $e');
    } finally {
      client.close();
    }
  }
}
