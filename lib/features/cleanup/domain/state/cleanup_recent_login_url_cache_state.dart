import 'package:core/core.dart';

class CleanupRecentLoginUrlCacheSuccess extends UIState {

  CleanupRecentLoginUrlCacheSuccess();

  @override
  List<Object> get props => [];
}

class CleanupRecentLoginUrlCacheFailure extends FeatureFailure {
  final dynamic exception;

  CleanupRecentLoginUrlCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}