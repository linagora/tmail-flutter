import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GettingThreadById extends LoadingState {}

class GetThreadByIdSuccess extends UIState {
  final List<EmailId> emailIds;

  GetThreadByIdSuccess(this.emailIds);

  @override
  List<Object> get props => [emailIds];
}

class GetThreadByIdFailure extends FeatureFailure {
  GetThreadByIdFailure({super.exception, super.onRetry});
}