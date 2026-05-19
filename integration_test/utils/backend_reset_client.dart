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
      // Swallow — test outcome must not depend on reset-server availability
    } finally {
      dio.close();
    }
  }

  /// POSTs [report] JSON to /timing so the host-side reset server can emit
  /// a [TIMING_REPORT] tag to its stdout log, which the report generator parses.
  /// Works on any platform where RESET_SERVER_URL is reachable (Android, Web).
  static Future<void> postTiming(Map<String, dynamic> report) async {
    if (!isEnabled) return;

    final dio = Dio();

    try {
      await dio.post(
        '$_resetUrl/timing',
        data: report,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Timing data loss is acceptable — don't fail the test
    } finally {
      dio.close();
    }
  }

  /// POSTs a named event to /event. The reset server timestamps it server-side
  /// and emits [EVENT] to its log, enabling patrol framework overhead analysis
  /// between harness lifecycle hooks and test execution phases.
  static Future<void> postEvent(String event) async {
    if (!isEnabled) return;

    final dio = Dio();

    try {
      await dio.post(
        '$_resetUrl/event',
        data: {'event': event},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      // Event data loss is acceptable — don't fail the test
    } finally {
      dio.close();
    }
  }
}
