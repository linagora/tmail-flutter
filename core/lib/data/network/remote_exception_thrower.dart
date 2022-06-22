
import 'package:core/domain/exceptions/remote_exception.dart';
import 'package:dio/dio.dart';

class RemoteExceptionThrower {
  void throwRemoteException(dynamic exception, {Function(DioError)? handler}) {
    if (exception is DioError) {
      switch (exception.type) {
        case DioErrorType.connectTimeout:
          throw ConnectError();
        default:
          if (handler != null) {
            throw handler(exception);
          } else {
            throw UnknownError(
              code: exception.response?.statusCode,
              message: exception.message);
          }
      }
    } else {
      throw UnknownError(message: exception.toString());
    }
  }
}
