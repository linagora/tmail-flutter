import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GettingEmailIdsByThreadId extends LoadingState {}

class GetEmailIdsByThreadIdSuccess extends UIState {
  final List<EmailId> emailIds;

  GetEmailIdsByThreadIdSuccess(this.emailIds);

  @override
  List<Object> get props => [emailIds];
}

class GetEmailIdsByThreadIdFailure extends FeatureFailure {
  GetEmailIdsByThreadIdFailure({super.exception});
}