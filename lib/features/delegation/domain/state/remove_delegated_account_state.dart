import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:delegation/model/delegated_account.dart';

class RemovingDelegatedAccount extends LoadingState {}

class RemoveDelegatedAccountSuccess extends UIState {
  final DelegatedAccount removedAccount;

  RemoveDelegatedAccountSuccess(this.removedAccount);

  @override
  List<Object?> get props => [removedAccount];
}

class RemoveDelegatedAccountFailure extends FeatureFailure {
  RemoveDelegatedAccountFailure(dynamic exception) : super(exception: exception);
}
