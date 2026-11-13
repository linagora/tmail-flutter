import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:delegation/model/delegated_account.dart';

class GettingDelegatedAccounts extends LoadingState {}

class GetDelegatedAccountsSuccess extends UIState {
  final List<DelegatedAccount> delegatedAccounts;

  GetDelegatedAccountsSuccess(this.delegatedAccounts);

  @override
  List<Object?> get props => [delegatedAccounts];
}

class GetDelegatedAccountsFailure extends FeatureFailure {
  GetDelegatedAccountsFailure(dynamic exception) : super(exception: exception);
}
