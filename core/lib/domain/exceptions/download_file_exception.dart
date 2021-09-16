import 'package:equatable/equatable.dart';

abstract class DownloadFileException with EquatableMixin implements Exception {
  final String message;

  DownloadFileException(this.message);

  @override
  String toString() => message;

  @override
  List<Object> get props => [message];
}

class CommonDownloadFileException extends DownloadFileException {
  CommonDownloadFileException(message) : super(message);

  @override
  List<Object> get props => [message];
}

class CancelDownloadFileException extends DownloadFileException {
  CancelDownloadFileException(cancelMessage) : super(cancelMessage);

  @override
  List<Object> get props => [message];
}

class DeviceNotSupportedException extends DownloadFileException {
  DeviceNotSupportedException() : super('This device is not supported, please try on Android or iOS');
}