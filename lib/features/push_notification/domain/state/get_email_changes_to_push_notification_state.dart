
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailChangesToPushNotificationLoading extends UIState {}

class GetEmailChangesToPushNotificationSuccess extends UIState {

  final List<PresentationEmail> emailList;
  final AccountId accountId;
  final UserName userName;

  GetEmailChangesToPushNotificationSuccess(this.accountId, this.userName, this.emailList);

  @override
  List<Object> get props => [accountId, userName, emailList];
}

class GetEmailChangesToPushNotificationFailure extends FeatureFailure {

  GetEmailChangesToPushNotificationFailure(exception) : super(exception: exception);
}