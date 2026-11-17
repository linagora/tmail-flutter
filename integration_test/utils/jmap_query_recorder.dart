import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import 'utc_clock.dart';

const _maxEntries = 20;
const _queryMethod = 'Email/query';
const _getMethod = 'Email/get';
const _seqKey = 'jmapQueryRecorderSeq';

// Buffers Email/query calls, the paired Email/get and errors, tagged #seq per HTTP request;
// printed on failure to tell a client bug from a server that returned nothing.
class JmapQueryRecorder extends Interceptor {
  JmapQueryRecorder._();

  static final instance = JmapQueryRecorder._();

  final _entries = <String>[];
  final _querySeqs = <int>{};
  var _seq = 0;
  Dio? _dio;

  void attach() {
    if (_dio != null) return;
    _dio = Get.find<Dio>()..interceptors.add(this);
  }

  void detach() {
    _dio?.interceptors.remove(this);
    _dio = null;
    _entries.clear();
    _querySeqs.clear();
    _seq = 0;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Dio fixes its interceptor chain per request, so a detached recorder can still be called.
    if (_dio != null) {
      final seq = ++_seq;
      options.extra[_seqKey] = seq;
      recordRequest(options.data, seq: seq);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_dio != null) {
      recordResponse(response.data, seq: response.requestOptions.extra[_seqKey] as int?);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_dio != null) {
      recordError(
        err.requestOptions.extra[_seqKey] as int?,
        '${err.type.name} status=${err.response?.statusCode}',
      );
    }
    handler.next(err);
  }

  @visibleForTesting
  void recordRequest(dynamic body, {int? seq}) =>
      _forEachCall(body, 'methodCalls', (method, args) {
        if (method != _queryMethod) return;
        if (seq != null) _querySeqs.add(seq);
        _add(
          seq,
          'request filter=${jsonEncode(args['filter'])} sort=${jsonEncode(args['sort'])} '
          'position=${args['position']} anchor=${args['anchor']} limit=${args['limit']} '
          'collapseThreads=${args['collapseThreads']}',
        );
      });

  @visibleForTesting
  void recordResponse(dynamic body, {int? seq}) {
    // Only responses to a recorded Email/query request; seq null = direct test call.
    if (seq != null && !_querySeqs.remove(seq)) return;
    _forEachCall(body, 'methodResponses', (method, args) {
      if (method == _queryMethod) {
        _add(
          seq,
          'response ids=${_length(args['ids'])} total=${args['total']} '
          'position=${args['position']} queryState=${args['queryState']}',
        );
      } else if (method == _getMethod) {
        _add(seq, 'get list=${_length(args['list'])} notFound=${_length(args['notFound'])}');
      } else if (method == 'error') {
        _add(seq, 'method error ${jsonEncode(args)}');
      }
    });
  }

  @visibleForTesting
  void recordError(int? seq, String reason) {
    if (seq == null || !_querySeqs.remove(seq)) return;
    _add(seq, 'failed $reason');
  }

  String _length(dynamic value) => value is List ? '${value.length}' : 'n/a';

  void _forEachCall(
    dynamic body,
    String listKey,
    void Function(String method, Map<String, dynamic> args) onCall,
  ) {
    try {
      // The request body holds model objects; round-trip it to plain JSON.
      final json = jsonDecode(jsonEncode(body, toEncodable: (o) => o.toString()));
      final calls = json is Map ? json[listKey] : null;
      if (calls is! List) return;
      for (final call in calls) {
        if (call is! List || call.length < 2 || call[0] is! String) continue;
        final args = call[1];
        if (args is Map<String, dynamic>) onCall(call[0] as String, args);
      }
    } catch (e) {
      _add(null, '$listKey record failed: $e');
    }
  }

  void _add(int? seq, String text) {
    _entries.add('at=${utcClock()} #${seq ?? '-'} $text');
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }

  void dump() {
    for (var i = 0; i < _entries.length; i++) {
      debugPrintSynchronously('[EMAIL QUERY] $i ${_entries[i]}');
    }
  }
}
