
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

class GetStoredSendingEmailLoading extends UIState {}

class GetStoredSendingEmailSuccess extends UIState {

  final SendingEmail sendingEmail;
  final AccountId accountId;
  final UserName userName;
  final SendingState sendingState;

  GetStoredSendingEmailSuccess(
    this.sendingEmail,
    this.accountId,
    this.userName,
    this.sendingState
  );

  @override
  List<Object?> get props => [
    sendingEmail,
    accountId,
    userName,
    sendingState
  ];
}

class GetStoredSendingEmailFailure extends FeatureFailure {

  GetStoredSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}