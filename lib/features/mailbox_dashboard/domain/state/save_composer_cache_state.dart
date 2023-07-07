import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveComposerCacheSuccess extends UIState {}

class SaveComposerCacheFailure extends FeatureFailure {

  SaveComposerCacheFailure(dynamic exception) : super(exception: exception);
}