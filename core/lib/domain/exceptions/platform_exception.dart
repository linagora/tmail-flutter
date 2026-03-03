import 'package:core/domain/exceptions/app_base_exception.dart';

class PlatformException extends AppBaseException {
  const PlatformException(super.message);

  @override
  String get exceptionName => 'PlatformException';
}

class NoSupportPlatformException extends PlatformException {
  const NoSupportPlatformException() : super('This platform is not supported');

  @override
  String get exceptionName => 'NoSupportPlatformException';
}
