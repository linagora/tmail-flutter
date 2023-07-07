import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class VerifyNameViewState extends UIState {}

class VerifyNameFailure extends FeatureFailure {

  VerifyNameFailure(dynamic exception) : super(exception: exception);
}