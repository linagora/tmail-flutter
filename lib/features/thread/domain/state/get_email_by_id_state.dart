import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailByIdLoading extends LoadingState {}

class GetEmailByIdSuccess extends UIState {
  final PresentationEmail email;

  GetEmailByIdSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

class GetEmailByIdFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailByIdFailure(this.exception);

  @override
  List<Object> get props => [exception];
}