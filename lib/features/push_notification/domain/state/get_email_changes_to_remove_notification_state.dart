
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GetEmailChangesToRemoveNotificationLoading extends UIState {}

class GetEmailChangesToRemoveNotificationSuccess extends UIState {

  final UserName userName;
  final List<EmailId> emailIds;

  GetEmailChangesToRemoveNotificationSuccess(this.userName, this.emailIds);

  @override
  List<Object> get props => [userName, emailIds];
}

class GetEmailChangesToRemoveNotificationFailure extends FeatureFailure {

  GetEmailChangesToRemoveNotificationFailure(exception) : super(exception: exception);
}