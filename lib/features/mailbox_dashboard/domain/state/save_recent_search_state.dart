import 'package:core/core.dart';

class SaveRecentSearchSuccess extends UIState {

  SaveRecentSearchSuccess();

  @override
  List<Object> get props => [];
}

class SaveRecentSearchFailure extends FeatureFailure {
  final dynamic exception;

  SaveRecentSearchFailure(this.exception);

  @override
  List<Object> get props => [exception];
}