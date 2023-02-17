import 'package:core/core.dart';

class DeleteIdentityLoading extends UIState {}

class DeleteIdentitySuccess extends UIState {

  DeleteIdentitySuccess();

  @override
  List<Object?> get props => [];
}

class DeleteIdentityFailure extends FeatureFailure {
  final dynamic exception;

  DeleteIdentityFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}