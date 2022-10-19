import 'package:core/core.dart';

class EditIdentityLoading extends UIState {}

class EditIdentitySuccess extends UIState {

  EditIdentitySuccess();

  @override
  List<Object?> get props => [];
}

class EditIdentityFailure extends FeatureFailure {
  final dynamic exception;

  EditIdentityFailure(this.exception);

  @override
  List<Object> get props => [exception];
}