import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class GettingEmailsByIds extends LoadingState {}

class GetEmailsByIdsSuccess extends UIState {
  GetEmailsByIdsSuccess(this.presentationEmails);

  final List<PresentationEmail> presentationEmails;

  @override
  List<Object?> get props => [presentationEmails];
}

class GetEmailsByIdsFailure extends FeatureFailure {
  GetEmailsByIdsFailure({super.exception});
}