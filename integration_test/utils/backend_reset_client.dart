import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Calls the backend reset server running on the CI host.
///
/// Only active when RESET_SERVER_URL is provided via --dart-define,
/// so local runs without the reset server are unaffected.
///
/// Uses Dio instead of dart:io so it works on all platforms including web.
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

    final dio = Dio(
      BaseOptions(
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );

    try {
      final response = await dio.post('$_resetUrl/reset');
      if (response.statusCode != 200) {
        throw Exception('Backend reset failed with status ${response.statusCode}');
      }
    } catch (e) {
      logWarning('Backend reset failed: $e');
    } finally {
      dio.close();
    }
  }
}
