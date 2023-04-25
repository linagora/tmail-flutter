
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailChangesToPushNotificationLoading extends UIState {}

class GetEmailChangesToPushNotificationSuccess extends UIState {

  final List<PresentationEmail> emailList;
  final AccountId accountId;

  GetEmailChangesToPushNotificationSuccess(this.accountId, this.emailList);

  @override
  List<Object> get props => [accountId, emailList];
}

class GetEmailChangesToPushNotificationFailure extends FeatureFailure {

  GetEmailChangesToPushNotificationFailure(exception) : super(exception: exception);

  @override
  List<Object> get props => [exception];
}