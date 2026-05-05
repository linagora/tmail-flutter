import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemoveAllComposerCacheSuccess extends UIState {}

class RemoveAllComposerCacheFailure extends FeatureFailure {
  RemoveAllComposerCacheFailure(Object? exception) : super(exception: exception);
}