import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';

import 'test_backend.dart';

/// Leases and releases isolated backends on the backend reset server running on the CI host.
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

  /// Leases a backend; the server holds the request until one is free.
  static Future<TestBackend> lease({
    // Longer than the server's LEASE_TIMEOUT (300 s), so the server answers first.
    Duration timeout = const Duration(minutes: 6),
  }) async {
    final dio = _newDio(timeout);
    try {
      final response = await dio.post<Map<String, dynamic>>('$_resetUrl/lease');
      final data = response.data!;
      return TestBackend(
        url: data['url'] as String,
        token: data['token'] as String,
      );
    } catch (e) {
      logWarning('Backend lease failed: $e');
      rethrow;
    } finally {
      dio.close();
    }
  }

  /// Hands the backend back; the server replaces it in the background.
  static Future<void> release(
    TestBackend backend, {
    Duration timeout = const Duration(minutes: 1),
  }) async {
    final token = backend.token;
    if (!isEnabled || token == null) return;

    final dio = _newDio(timeout);
    try {
      await dio.post('$_resetUrl/release', data: {'token': token});
    } catch (e) {
      logWarning('Backend release failed: $e');
      rethrow;
    } finally {
      dio.close();
    }
  }

  static Dio _newDio(Duration timeout) => Dio(
        BaseOptions(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
}
