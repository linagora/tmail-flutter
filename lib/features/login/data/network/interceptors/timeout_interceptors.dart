import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class TimeoutInterceptors extends InterceptorsWrapper {
  Duration? _connectionTimeout;
  Duration? _sendTimeout;
  Duration? _receiveTimeout;

  @visibleForTesting
  Duration? get connectionTimeout => _connectionTimeout;

  @visibleForTesting
  Duration? get sendTimeout => _sendTimeout;

  @visibleForTesting
  Duration? get receiveTimeout => _receiveTimeout;

  void setTimeout({
    required Duration connectionTimeout,
    required Duration sendTimeout,
    required Duration receiveTimeout,
  }) {
    _connectionTimeout = connectionTimeout;
    _sendTimeout = sendTimeout;
    _receiveTimeout = receiveTimeout;
  }

  void resetTimeout() {
    _connectionTimeout = null;
    _sendTimeout = null;
    _receiveTimeout = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout = _connectionTimeout;
    options.sendTimeout = _sendTimeout;
    options.receiveTimeout = _receiveTimeout;
    super.onRequest(options, handler);
  }
}