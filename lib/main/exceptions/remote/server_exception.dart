import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class ServerException extends RemoteException {
  const ServerException({super.code, super.message});

  @override
  String get exceptionName => 'ServerException';
}

class InternalServerError extends ServerException {
  const InternalServerError()
      : super(message: 'Internal Server Error');

  @override
  String get exceptionName => 'InternalServerError';
}