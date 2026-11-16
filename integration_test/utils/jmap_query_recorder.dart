import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

const _maxEntries = 20;
const _queryMethod = 'Email/query';

// Buffers the Email/query calls the app sends and what the server answers; printed on failure
// to tell a client filter bug from a server that returned nothing.
class JmapQueryRecorder extends Interceptor {
  JmapQueryRecorder._();

  static final instance = JmapQueryRecorder._();

  final _entries = <String>[];
  final _clock = Stopwatch();
  Dio? _dio;

  void attach() {
    if (_dio != null) return;
    _dio = Get.find<Dio>()..interceptors.add(this);
    _clock
      ..reset()
      ..start();
  }

  void detach() {
    _dio?.interceptors.remove(this);
    _dio = null;
    _entries.clear();
    _clock.stop();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Dio fixes its interceptor chain per request, so a detached recorder can still be called.
    if (_dio != null) recordRequest(options.data);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_dio != null) recordResponse(response.data);
    handler.next(response);
  }

  @visibleForTesting
  void recordRequest(dynamic body) => _record(body, 'methodCalls', 'request', (args) {
        return 'filter=${jsonEncode(args['filter'])}';
      });

  @visibleForTesting
  void recordResponse(dynamic body) => _record(body, 'methodResponses', 'response', (args) {
        final ids = args['ids'];
        return 'ids=${ids is List ? ids.length : 'n/a'} total=${args['total']}';
      });

  void _record(
    dynamic body,
    String listKey,
    String label,
    String Function(Map<String, dynamic> args) describe,
  ) {
    try {
      // The request body holds model objects; round-trip it to plain JSON.
      final json = jsonDecode(jsonEncode(body, toEncodable: (o) => o.toString()));
      final calls = json is Map ? json[listKey] : null;
      if (calls is! List) return;
      for (final call in calls) {
        if (call is! List || call.length < 2 || call[0] != _queryMethod) continue;
        final args = call[1];
        if (args is! Map<String, dynamic>) continue;
        _add('$label ${describe(args)}');
      }
    } catch (e) {
      _add('$label record failed: $e');
    }
  }

  void _add(String text) {
    _entries.add('t=${_clock.elapsedMilliseconds}ms $text');
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }

  void dump() {
    for (var i = 0; i < _entries.length; i++) {
      debugPrintSynchronously('[EMAIL QUERY] $i ${_entries[i]}');
    }
  }
}
