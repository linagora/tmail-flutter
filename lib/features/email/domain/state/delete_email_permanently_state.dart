import 'package:core/core.dart';

class DeleteEmailPermanentlySuccess extends UIState {

  DeleteEmailPermanentlySuccess();

  @override
  List<Object?> get props => [];
}

class DeleteEmailPermanentlyFailure extends FeatureFailure {

  final exception;

  DeleteEmailPermanentlyFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}