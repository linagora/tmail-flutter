import 'package:equatable/equatable.dart';

class PlatformException with EquatableMixin implements Exception {
  final String message;

  PlatformException(this.message);

  @override
  List<Object> get props => [message];
}

class NoSupportPlatformException extends PlatformException {
  NoSupportPlatformException() : super('This platform is not supported');
}