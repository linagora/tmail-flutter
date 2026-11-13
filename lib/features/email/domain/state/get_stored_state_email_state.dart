import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';

class GetStoredEmailStateSuccess extends UIState {

  final jmap.State state;
  final AccountId accountId;
  final UserName userName;

  GetStoredEmailStateSuccess(this.state, this.accountId, this.userName);

  @override
  List<Object> get props => [state, accountId, userName];
}

class NotFoundEmailState extends FeatureFailure {}

class GetStoredEmailStateFailure extends FeatureFailure {

  GetStoredEmailStateFailure(dynamic exception) : super(exception: exception);
}