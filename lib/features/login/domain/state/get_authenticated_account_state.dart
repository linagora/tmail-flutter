import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/account.dart';

class NoAuthenticatedAccountFailure extends FeatureFailure {

  NoAuthenticatedAccountFailure();

  @override
  List<Object?> get props => [];
}

class GetAuthenticatedAccountSuccess extends UIState {
  final Account account;

  GetAuthenticatedAccountSuccess(this.account);

  @override
  List<Object> get props => [account];
}

class GetAuthenticatedAccountFailure extends FeatureFailure {
  final exception;

  GetAuthenticatedAccountFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}
