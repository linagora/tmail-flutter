import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class MarkComposerCacheCleanCloseSuccess extends UIState {}

class MarkComposerCacheCleanCloseFailure extends FeatureFailure {
  MarkComposerCacheCleanCloseFailure(Object? exception) : super(exception: exception);
}