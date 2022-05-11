import 'package:core/core.dart';

class StoreRecentSearchSuccess extends UIState {

  StoreRecentSearchSuccess();

  @override
  List<Object?> get props => [];
}

class StoreRecentSearchSuccessFailure extends FeatureFailure {
  final dynamic exception;

  StoreRecentSearchSuccessFailure(this.exception);

  @override
  List<Object> get props => [exception];
}