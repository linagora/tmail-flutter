import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreComposedEmailToLocalStorageBrowserLoading extends LoadingState {}

class StoreComposedEmailToLocalStorageBrowserSuccess extends UIState {}

class StoreComposedEmailToLocalStorageBrowserFailure extends FeatureFailure {

  StoreComposedEmailToLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}