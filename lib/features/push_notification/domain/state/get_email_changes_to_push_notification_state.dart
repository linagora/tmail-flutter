
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/presentation_email.dart';

class GetEmailChangesToPushNotificationLoading extends UIState {}

class GetEmailChangesToPushNotificationSuccess extends UIState {

  final List<PresentationEmail> emailList;
  final AccountId accountId;
  final UserName userName;

  /// Push delivery state this query was started for.
  ///
  /// Stored only when it is still the latest push for the account, so a newer
  /// push that arrived while the query was in flight is not skipped.
  final jmap.State? deliveryState;

  GetEmailChangesToPushNotificationSuccess(
    this.accountId,
    this.userName,
    this.emailList, {
    this.deliveryState,
  });

  @override
  List<Object?> get props => [accountId, userName, emailList, deliveryState];
}

class GetEmailChangesToPushNotificationFailure extends FeatureFailure {

  GetEmailChangesToPushNotificationFailure(exception) : super(exception: exception);
}