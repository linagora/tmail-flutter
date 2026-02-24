import 'package:core/domain/exceptions/app_base_exception.dart';

class WebSocketPushNotSupportedException extends AppBaseException {
  WebSocketPushNotSupportedException([super.message]);

  @override
  String get exceptionName => 'WebSocketPushNotSupportedException';
}

class WebSocketUriUnavailableException extends AppBaseException {
  WebSocketUriUnavailableException([super.message]);

  @override
  String get exceptionName => 'WebSocketUriUnavailableException';
}

class WebSocketTicketUnavailableException extends AppBaseException {
  WebSocketTicketUnavailableException([super.message]);

  @override
  String get exceptionName => 'WebSocketTicketUnavailableException';
}

class WebSocketClosedException extends AppBaseException {
  WebSocketClosedException([super.message]);

  @override
  String get exceptionName => 'WebSocketClosedException';
}
