import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';

class GetDetailedEmailByIdLoading extends UIState {}

class GetDetailedEmailByIdSuccess extends UIState {

  final PresentationEmail presentationEmail;
  final DetailedEmail detailedEmail;

  GetDetailedEmailByIdSuccess(this.presentationEmail, this.detailedEmail);

  @override
  List<Object?> get props => [presentationEmail, detailedEmail];
}

class GetDetailedEmailByIdFailure extends FeatureFailure {

  GetDetailedEmailByIdFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}