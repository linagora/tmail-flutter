import 'package:core/core.dart';
import 'package:core/presentation/state/failure.dart';

class DeleteCredentialSuccess extends UIState {
  DeleteCredentialSuccess();

  @override
  List<Object> get props => [];
}

class DeleteCredentialFailure extends FeatureFailure {
  final exception;

  DeleteCredentialFailure(this.exception);

  @override
  List<Object> get props => [exception];
}