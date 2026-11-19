import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreDelegatedNotificationBaselinesLoading extends LoadingState {}

class StoreDelegatedNotificationBaselinesSuccess extends UIState {}

class StoreDelegatedNotificationBaselinesFailure extends FeatureFailure {
  StoreDelegatedNotificationBaselinesFailure(dynamic exception) : super(exception: exception);
}
