import 'package:core/core.dart';

class CleanupRecentLoginUsernameCacheSuccess extends UIState {

  CleanupRecentLoginUsernameCacheSuccess();

  @override
  List<Object> get props => [];
}

class CleanupRecentLoginUsernameCacheFailure extends FeatureFailure {
  final dynamic exception;

  CleanupRecentLoginUsernameCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}