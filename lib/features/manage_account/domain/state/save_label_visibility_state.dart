import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SavingLabelVisibility extends LoadingState {}

class SaveLabelVisibilitySuccess extends UIState {}

class SaveLabelVisibilityFailure extends FeatureFailure {
  SaveLabelVisibilityFailure(dynamic exception) : super(exception: exception);
}
