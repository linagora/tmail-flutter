import 'package:core/core.dart';

class CleanupEmailCacheSuccess extends UIState {

  CleanupEmailCacheSuccess();

  @override
  List<Object> get props => [];
}

class CleanupEmailCacheFailure extends FeatureFailure {
  final dynamic exception;

  CleanupEmailCacheFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}