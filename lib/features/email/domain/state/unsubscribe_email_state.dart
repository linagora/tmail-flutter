import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class UnsubscribeEmailLoading extends LoadingState {}

class UnsubscribeEmailSuccess extends UIState {
  UnsubscribeEmailSuccess(this.emailId);

  final EmailId emailId;

  @override
  List<Object?> get props => [emailId];
}

class UnsubscribeEmailFailure extends FeatureFailure {

  UnsubscribeEmailFailure({dynamic exception}) : super(exception: exception);
}