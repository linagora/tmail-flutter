
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';

class GetStoredEmailDeliveryStateLoading extends UIState {}

class GetStoredEmailDeliveryStateSuccess extends UIState {

  final jmap.State state;
  final AccountId accountId;
  final UserName userName;

  GetStoredEmailDeliveryStateSuccess(this.state, this.accountId, this.userName);

  @override
  List<Object> get props => [state, accountId, userName];
}

class GetStoredEmailDeliveryStateFailure extends FeatureFailure {

  final AccountId? accountId;
  final UserName? userName;

  GetStoredEmailDeliveryStateFailure(
    dynamic exception, {
    this.accountId,
    this.userName,
  }) : super(exception: exception);
}