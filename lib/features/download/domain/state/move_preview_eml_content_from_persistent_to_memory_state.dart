import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class MovingPreviewEmailEMLContentFromPersistentToMemory extends LoadingState {}

class MovePreviewEmailEMLContentFromPersistentToMemorySuccess extends UIState {}

class MovePreviewEmailEMLContentFromPersistentToMemoryFailure extends FeatureFailure {

  MovePreviewEmailEMLContentFromPersistentToMemoryFailure(dynamic exception) : super(exception: exception);
}