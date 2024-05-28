import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteComposedEmailOnLocalStorageBrowserLoading extends LoadingState {}

class DeleteComposedEmailOnLocalStorageBrowserSuccess extends UIState {}

class DeleteComposedEmailOnLocalStorageBrowserFailure extends FeatureFailure {

  DeleteComposedEmailOnLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}