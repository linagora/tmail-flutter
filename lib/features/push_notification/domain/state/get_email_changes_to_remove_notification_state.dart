
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GetEmailChangesToRemoveNotificationLoading extends UIState {}

class GetEmailChangesToRemoveNotificationSuccess extends UIState {

  final List<EmailId> emailIds;

  GetEmailChangesToRemoveNotificationSuccess(this.emailIds);

  @override
  List<Object> get props => [emailIds];
}

class GetEmailChangesToRemoveNotificationFailure extends FeatureFailure {

  GetEmailChangesToRemoveNotificationFailure(exception) : super(exception: exception);

  @override
  List<Object> get props => [exception];
}