import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class UnsubscribeEmailLoading extends LoadingState {}

class UnsubscribeEmailSuccess extends UIState {}

class UnsubscribeEmailFailure extends FeatureFailure {

  UnsubscribeEmailFailure({dynamic exception}) : super(exception: exception);
}