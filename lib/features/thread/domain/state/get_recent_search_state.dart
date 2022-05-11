import 'package:core/core.dart';

class GetRecentSearchSuccess extends UIState {

  GetRecentSearchSuccess();

  @override
  List<Object?> get props => [];
}

class GetRecentSearchFailure extends FeatureFailure {
  final dynamic exception;

  GetRecentSearchFailure(this.exception);

  @override
  List<Object> get props => [exception];
}