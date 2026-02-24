import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:equatable/equatable.dart';

class PlatformException extends AppBaseException with EquatableMixin {
  const PlatformException(super.message);

  @override
  String get exceptionName => 'PlatformException';

  @override
  List<Object?> get props => [message, exceptionName];
}

class NoSupportPlatformException extends PlatformException {
  const NoSupportPlatformException() : super('This platform is not supported');

  @override
  String get exceptionName => 'NoSupportPlatformException';
}
