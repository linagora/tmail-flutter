import 'package:equatable/equatable.dart';

abstract class AppBaseException with EquatableMixin implements Exception {
  final String? message;

  const AppBaseException([this.message]);

  @override
  String toString() {
    if (message?.isNotEmpty == true) {
      return '$exceptionName: $message';
    }
    return exceptionName;
  }

  String get exceptionName;

  @override
  List<Object?> get props => [message];
}
