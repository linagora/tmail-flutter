import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class UnknownRemoteException extends RemoteException {
  const UnknownRemoteException({
    super.code,
    super.message,
  });

  @override
  String get exceptionName => 'UnknownRemoteException';
}
