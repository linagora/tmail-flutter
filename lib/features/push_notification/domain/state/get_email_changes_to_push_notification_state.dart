import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailChangesToPushNotificationLoading extends LoadingState {}

class GetEmailChangesToPushNotificationSuccess extends UIState {
  final List<PresentationEmail> emailList;
  final AccountId accountId;
  final UserName userName;
  final State currentState;

  GetEmailChangesToPushNotificationSuccess(
    this.accountId,
    this.userName,
    this.emailList,
    this.currentState,
  );

  @override
  List<Object> get props => [accountId, userName, emailList, currentState];
}

class GetEmailChangesToPushNotificationFailure extends FeatureFailure {
  final State currentState;

  GetEmailChangesToPushNotificationFailure({
    super.exception,
    super.stackTrace,
    super.onRetry,
    required this.currentState,
  });
}
