import 'package:core/core.dart';

class CleanupRecentSearchCacheSuccess extends UIState {

  CleanupRecentSearchCacheSuccess();

  @override
  List<Object> get props => [];
}

class CleanupRecentSearchCacheFailure extends FeatureFailure {
  final dynamic exception;

  CleanupRecentSearchCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}