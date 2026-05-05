import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemoveComposerCacheByIdSuccess extends UIState {}

class RemoveComposerCacheByIdFailure extends FeatureFailure {
  RemoveComposerCacheByIdFailure(dynamic exception) : super(exception: exception);
}