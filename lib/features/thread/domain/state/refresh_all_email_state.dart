import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RefreshingAllEmail extends LoadingState {}

class RefreshAllEmailSuccess extends UIState {}

class RefreshAllEmailFailure extends FeatureFailure {

  RefreshAllEmailFailure({dynamic exception}) : super(exception: exception);
}