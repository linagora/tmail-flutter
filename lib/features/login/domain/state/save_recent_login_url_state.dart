import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveRecentLoginUrlSuccess extends UIState {}

class SaveRecentLoginUrlFailed extends FeatureFailure {

  SaveRecentLoginUrlFailed(dynamic exception) : super(exception: exception);
}