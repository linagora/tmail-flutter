import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/personal_account.dart';

class GetCurrentAccountCacheLoading extends LoadingState {}

class GetCurrentAccountCacheSuccess extends UIState {
  final PersonalAccount account;
  final StateChange? stateChange;

  GetCurrentAccountCacheSuccess(this.account, this.stateChange);

  @override
  List<Object> get props => [account];
}

class GetCurrentAccountCacheFailure extends FeatureFailure {

  GetCurrentAccountCacheFailure(dynamic exception) : super(exception: exception);
}
