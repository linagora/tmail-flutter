import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class NoAuthenticatedAccountFailure extends FeatureFailure {

  NoAuthenticatedAccountFailure();

  @override
  List<Object?> get props => [];
}

class GetAuthenticatedAccountSuccess extends UIState {
  final PersonalAccount account;

  GetAuthenticatedAccountSuccess(this.account);

  @override
  List<Object> get props => [account];
}

class GetAuthenticatedAccountFailure extends FeatureFailure {
  GetAuthenticatedAccountFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}
