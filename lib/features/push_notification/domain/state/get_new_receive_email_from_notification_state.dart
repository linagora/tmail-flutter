
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GetNewReceiveEmailFromNotificationLoading extends UIState {}

class GetNewReceiveEmailFromNotificationSuccess extends UIState {

  final List<EmailId> emailIds;
  final AccountId accountId;
  final Session? session;

  GetNewReceiveEmailFromNotificationSuccess(this.accountId, this.session, this.emailIds);

  @override
  List<Object?> get props => [accountId, session, emailIds];
}

class GetNewReceiveEmailFromNotificationFailure extends FeatureFailure {

  GetNewReceiveEmailFromNotificationFailure(exception) : super(exception: exception);
}