
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailChangesToPushNotificationLoading extends UIState {}

class GetEmailChangesToPushNotificationSuccess extends UIState {

  final List<PresentationEmail> emailList;

  GetEmailChangesToPushNotificationSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class GetEmailChangesToPushNotificationFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailChangesToPushNotificationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}