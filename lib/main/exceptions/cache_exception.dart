import 'package:equatable/equatable.dart';

abstract class CacheException with EquatableMixin implements Exception {
  final String? message;

  const CacheException({this.message});

  String get exceptionName;

  @override
  String toString() {
    if (message?.trim().isNotEmpty == true) {
      return '$exceptionName: $message';
    }
    return exceptionName;
  }
}

class UnknownCacheError extends CacheException {
  const UnknownCacheError({String? message}) : super(message: message);

  @override
  String get exceptionName => 'UnknownCacheError';

  @override
  List<Object?> get props => [message];
}
