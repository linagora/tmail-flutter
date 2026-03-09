import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class NetworkException extends RemoteException {
  const NetworkException({super.message});

  @override
  String get exceptionName => 'NetworkException';
}

class NoNetworkError extends NetworkException {
  const NoNetworkError() : super(message: 'No network connection');

  @override
  String get exceptionName => 'NoNetworkError';
}

class ConnectionError extends NetworkException {
  const ConnectionError({String? message})
      : super(message: message ?? 'Connection error');

  @override
  String get exceptionName => 'ConnectionError';
}

class ConnectionTimeout extends NetworkException {
  const ConnectionTimeout({String? message})
      : super(message: message ?? 'Connection timeout');

  @override
  String get exceptionName => 'ConnectionTimeout';
}

class SocketError extends NetworkException {
  const SocketError() : super(message: 'Socket exception');

  @override
  String get exceptionName => 'SocketError';
}
