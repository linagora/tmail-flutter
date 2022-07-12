import 'package:core/core.dart';

class SaveComposerCacheSuccess extends UIState {

  SaveComposerCacheSuccess();

  @override
  List<Object> get props => [];
}

class SaveComposerCacheFailure extends FeatureFailure {
  final dynamic exception;

  SaveComposerCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}