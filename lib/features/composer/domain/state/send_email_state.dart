import 'package:core/core.dart';

class SendingEmailState extends UIState {
  SendingEmailState();

  @override
  List<Object?> get props => [];
}

class SendEmailSuccess extends UIState {

  SendEmailSuccess();

  @override
  List<Object?> get props => [];
}

class SendEmailFailure extends FeatureFailure {
  final dynamic exception;

  SendEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}