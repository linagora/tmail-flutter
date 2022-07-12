import 'package:core/core.dart';

class RemoveComposerCacheSuccess extends UIState {

  RemoveComposerCacheSuccess();

  @override
  List<Object?> get props => [];
}

class RemoveComposerCacheFailure extends FeatureFailure {
  final dynamic exception;

  RemoveComposerCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}