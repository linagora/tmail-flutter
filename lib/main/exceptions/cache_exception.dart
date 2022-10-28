
import 'package:equatable/equatable.dart';

abstract class CacheException with EquatableMixin implements Exception {

  final String? message;

  const CacheException({this.message});
}

class UnknownCacheError extends CacheException {
  const UnknownCacheError({String? message}) : super(message: message);

  @override
  List<Object> get props => [];
}