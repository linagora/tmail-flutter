
import 'package:core/domain/exceptions/remote_exception.dart';
import 'package:dio/dio.dart';

class RemoteExceptionThrower {
  void throwRemoteException(dynamic exception, {Function(DioError)? handler}) {
    if (exception is DioError) {
      handler != null ? handler(exception) : throw UnknownError(exception.message);
    } else {
      throw UnknownError(exception.toString());
    }
  }
}
