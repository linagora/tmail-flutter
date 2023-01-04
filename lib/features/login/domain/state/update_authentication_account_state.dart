import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class UpdateAuthenticationAccountLoading extends LoadingState {}

class UpdateAuthenticationAccountSuccess extends UIState {

  UpdateAuthenticationAccountSuccess();

  @override
  List<Object> get props => [];
}

class UpdateAuthenticationAccountFailure extends FeatureFailure {
  final dynamic exception;

  UpdateAuthenticationAccountFailure(this.exception);
  
  @override
  List<Object?> get props => [exception];
}