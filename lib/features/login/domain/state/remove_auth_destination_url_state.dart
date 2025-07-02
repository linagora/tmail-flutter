import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemovingAuthDestinationUrl extends LoadingState {}

class RemoveAuthDestinationUrlSuccess extends UIState {}

class RemoveAuthDestinationUrlFailure extends FeatureFailure {
  RemoveAuthDestinationUrlFailure(dynamic exception)
      : super(exception: exception);
}
