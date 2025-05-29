import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class GettingEmailsByIds extends LoadingState {
  GettingEmailsByIds({this.loadingIndex});

  final int? loadingIndex;

  @override
  List<Object?> get props => [loadingIndex];
}

class GetEmailsByIdsSuccess extends UIState {
  GetEmailsByIdsSuccess(
    this.presentationEmails, {
    this.updateCurrentThreadDetail = false,
  });

  final List<PresentationEmail> presentationEmails;
  final bool updateCurrentThreadDetail;

  @override
  List<Object?> get props => [presentationEmails, updateCurrentThreadDetail];
}

class GetEmailsByIdsFailure extends FeatureFailure {
  GetEmailsByIdsFailure({super.exception, super.onRetry});
}