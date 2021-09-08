import 'package:core/core.dart';

class SendEmailSuccess extends UIState {

  SendEmailSuccess();

  @override
  List<Object?> get props => [];
}

class SendEmailFailure extends FeatureFailure {
  final exception;

  SendEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}