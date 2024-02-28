import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class PrintEmailLoading extends LoadingState {}

class PrintEmailSuccess extends UIState {}

class PrintEmailFailure extends FeatureFailure {

  PrintEmailFailure({dynamic exception}) : super(exception: exception);
}