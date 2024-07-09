import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveComposerCacheToLocalStorageBrowserLoading extends LoadingState {}

class SaveComposerCacheToLocalStorageBrowserSuccess extends UIState {}

class SaveComposerCacheToLocalStorageBrowserFailure extends FeatureFailure {

  SaveComposerCacheToLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}