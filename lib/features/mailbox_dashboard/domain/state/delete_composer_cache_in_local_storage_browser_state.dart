import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteComposeCacheInLocalStorageBrowserLoading extends LoadingState {}

class DeleteComposeCacheInLocalStorageBrowserSuccess extends UIState {}

class DeleteComposeCacheInLocalStorageBrowserFailure extends FeatureFailure {

  DeleteComposeCacheInLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}