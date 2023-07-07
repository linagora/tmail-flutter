import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class EditIdentityLoading extends UIState {}

class EditIdentitySuccess extends UIState {}

class EditIdentityFailure extends FeatureFailure {

  EditIdentityFailure(dynamic exception) : super(exception: exception);
}