
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GetNewReceiveEmailFromNotificationLoading extends UIState {}

class GetNewReceiveEmailFromNotificationSuccess extends UIState {

  final List<EmailId> emailIds;
  final AccountId accountId;
  final UserName userName;

  GetNewReceiveEmailFromNotificationSuccess(this.accountId, this.userName, this.emailIds);

  @override
  List<Object> get props => [accountId, userName, emailIds];
}

class GetNewReceiveEmailFromNotificationFailure extends FeatureFailure {

  GetNewReceiveEmailFromNotificationFailure(exception) : super(exception: exception);

  @override
  List<Object> get props => [exception];
}